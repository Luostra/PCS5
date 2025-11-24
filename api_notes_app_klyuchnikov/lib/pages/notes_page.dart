import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/notes_repository.dart';
import '../models/note.dart';
import 'note_details_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final NotesRepository repo;
  final List<Note> _items = [];
  final List<Note> _filteredItems = [];
  int _page = 1;
  bool _canLoadMore = true;
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final client = ApiClient(baseUrl: 'http://10.0.2.2:3000');
    repo = NotesRepository(client);
    _refresh();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _applyFilter();
      });
    });
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredItems.clear();
      _filteredItems.addAll(_items);
    } else {
      _filteredItems.clear();
      _filteredItems.addAll(
        _items.where(
          (note) =>
              note.title.toLowerCase().contains(_searchQuery) ||
              note.body.toLowerCase().contains(_searchQuery),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _canLoadMore = true;
      _items.clear();
      _filteredItems.clear();
      _searchController.clear();
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (!_canLoadMore || _loading) return;
    setState(() => _loading = true);
    try {
      final batch = await repo.list(page: _page, limit: 20);
      setState(() {
        _items.addAll(batch);
        _applyFilter();
        _canLoadMore = batch.length == 20;
        if (_canLoadMore) _page++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createNote() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateNoteDialog(),
    );

    if (result != null) {
      try {
        final newNote = await repo.create(result['title']!, result['body']!);
        setState(() {
          _items.insert(0, newNote);
          _applyFilter();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Заметка создана')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка создания: $e')));
      }
    }
  }

  Future<void> _deleteNote(int index, int id) async {
    final note = _filteredItems[index];
    final mainIndex = _items.indexWhere((item) => item.id == note.id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: Text('Заметка "${note.title}" будет удалена'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await repo.delete(id);
        setState(() {
          if (mainIndex != -1) {
            _items.removeAt(mainIndex);
          }
          _applyFilter();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Заметка удалена')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _searchQuery.isEmpty ? _items : _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Notes Feed'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по заголовку и тексту...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                        tooltip: 'Очистить поиск',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Найдено заметок: ${displayItems.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: _clearSearch,
                    child: const Text('Очистить'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: displayItems.isEmpty && _loading
                  ? const Center(child: CircularProgressIndicator())
                  : displayItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount:
                          displayItems.length +
                          (_canLoadMore && _searchQuery.isEmpty ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        if (i == displayItems.length &&
                            _canLoadMore &&
                            _searchQuery.isEmpty) {
                          _loadMore();
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (i >= displayItems.length) {
                          return const SizedBox.shrink();
                        }

                        final n = displayItems[i];
                        return Card(
                          child: ListTile(
                            title: _buildHighlightedText(
                              n.title,
                              _searchQuery,
                              Theme.of(context).textTheme.titleMedium!,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHighlightedText(
                                  n.body,
                                  _searchQuery,
                                  Theme.of(context).textTheme.bodyMedium!,
                                ),
                                if (_searchQuery.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'ID: ${n.id}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    NoteDetailsPage(id: n.id, repo: repo),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteNote(i, n.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, TextStyle style) {
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: query.isEmpty ? 2 : 3,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    final matches = <TextSpan>[];
    int start = 0;

    while (start < textLower.length) {
      final matchIndex = textLower.indexOf(queryLower, start);
      if (matchIndex == -1) {
        matches.add(TextSpan(text: text.substring(start), style: style));
        break;
      }

      if (matchIndex > start) {
        matches.add(
          TextSpan(text: text.substring(start, matchIndex), style: style),
        );
      }

      matches.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: style.copyWith(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.3),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = matchIndex + query.length;
    }

    return RichText(
      text: TextSpan(children: matches),
      maxLines: query.isEmpty ? 2 : 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_searchQuery.isNotEmpty)
            const Icon(Icons.search_off, size: 64, color: Colors.grey)
          else
            const Icon(Icons.note_add, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'По запросу "$_searchQuery" ничего не найдено'
                : 'Заметок пока нет',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Попробуйте изменить поисковый запрос'
                : 'Создайте первую заметку',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (!_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _createNote,
              child: const Text('Создать заметку'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class CreateNoteDialog extends StatefulWidget {
  @override
  _CreateNoteDialogState createState() => _CreateNoteDialogState();
}

class _CreateNoteDialogState extends State<CreateNoteDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новая заметка'),
      content: _isLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Текст заметки',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
              ],
            ),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  final body = _bodyController.text.trim();

                  if (title.isEmpty || body.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Заполните все поля')),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);

                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.of(context).pop({'title': title, 'body': body});
                  });
                },
                child: const Text('Создать'),
              ),
            ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
