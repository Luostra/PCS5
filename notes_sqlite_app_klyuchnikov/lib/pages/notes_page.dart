import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/note.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<List<Note>> _future;
  final _searchController = TextEditingController();
  final _dbHelper = DBHelper.instance;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _dbHelper.fetchNotes();
    });
  }

  void _searchNotes(String query) {
    setState(() {
      _future = _dbHelper.searchNotes(query);
    });
  }

  Future<void> _createDialog() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _EditDialog(
        titleCtrl: titleCtrl,
        bodyCtrl: bodyCtrl,
        title: 'Новая заметка',
        showFavorite: false,
      ),
    );

    if (ok == true && mounted) {
      final now = DateTime.now();
      await _dbHelper.insertNote(
        Note(
          title: titleCtrl.text.trim(),
          body: bodyCtrl.text.trim(),
          createdAt: now,
          updatedAt: now,
        ),
      );
      _reload();
    }
  }

  Future<void> _editDialog(Note n) async {
    final titleCtrl = TextEditingController(text: n.title);
    final bodyCtrl = TextEditingController(text: n.body);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _EditDialog(
        titleCtrl: titleCtrl,
        bodyCtrl: bodyCtrl,
        title: 'Редактировать',
        initialFavorite: n.isFavorite,
        showFavorite: true,
      ),
    );

    if (ok == true && mounted) {
      final updated = n.copyWith(
        title: titleCtrl.text.trim(),
        body: bodyCtrl.text.trim(),
        updatedAt: DateTime.now(),
      );
      await _dbHelper.updateNote(updated);
      _reload();
    }
  }

  Future<void> _delete(Note n) async {
    await _dbHelper.deleteNote(n.id!);
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Удалено')));
    _reload();
  }

  Future<void> _toggleFavorite(Note n) async {
    await _dbHelper.toggleFavorite(n.id!, !n.isFavorite);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes SQLite'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по заголовку...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchNotes('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchNotes,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Note>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Ошибка загрузки'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snap.data!;
          if (notes.isEmpty) {
            return const Center(child: Text('Пока нет заметок. Нажмите +'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final n = notes[i];
              return Dismissible(
                key: ValueKey(n.id),
                background: Container(
                  color: Theme.of(context).colorScheme.error.withOpacity(.1),
                ),
                onDismissed: (_) => _delete(n),
                child: Card(
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        n.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: n.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () => _toggleFavorite(n),
                    ),
                    title: Text(
                      n.title.isEmpty ? '(без названия)' : n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      n.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _editDialog(n),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(n),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _EditDialog extends StatefulWidget {
  final TextEditingController titleCtrl;
  final TextEditingController bodyCtrl;
  final String title;
  final bool showFavorite;
  final bool initialFavorite;

  const _EditDialog({
    required this.titleCtrl,
    required this.bodyCtrl,
    required this.title,
    this.showFavorite = false,
    this.initialFavorite = false,
  });

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.titleCtrl,
            decoration: const InputDecoration(labelText: 'Заголовок'),
          ),
          TextField(
            controller: widget.bodyCtrl,
            decoration: const InputDecoration(labelText: 'Текст'),
            maxLines: 3,
          ),
          if (widget.showFavorite) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('В избранном'),
                const Spacer(),
                Switch(
                  value: _isFavorite,
                  onChanged: (value) {
                    setState(() {
                      _isFavorite = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
