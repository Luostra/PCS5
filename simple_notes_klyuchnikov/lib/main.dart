import 'package:flutter/material.dart';
import 'models/note.dart';
import 'edit_note_page.dart';

void main() => runApp(const SimpleNotesApp());

class SimpleNotesApp extends StatelessWidget {
  const SimpleNotesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Notes',
      theme: ThemeData(useMaterial3: true),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> _notes = [
    Note(id: '1', title: 'Пример', body: 'Это пример заметки'),
  ];

  List<Note> _filteredNotes = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredNotes = _notes;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredNotes = _notes;
      });
    } else {
      setState(() {
        _filteredNotes = _notes.where((note) {
          return note.title.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  void _startSearch() {
    ModalRoute.of(
      context,
    )?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchController.clear();
      _filteredNotes = _notes;
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Поиск по заголовку...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, color: Colors.white),
          onPressed: _clearSearchQuery,
        ),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [];
    }

    return [
      IconButton(
        icon: Icon(Icons.search, color: Colors.white),
        onPressed: _startSearch,
      ),
    ];
  }

  Widget _buildAppBarTitle() {
    if (_isSearching) {
      return _buildSearchField();
    }

    return const Text('Simple Notes');
  }

  Future<void> _addNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage()),
    );
    if (newNote != null) {
      setState(() {
        _notes.add(newNote);
        // Обновляем отфильтрованный список после добавления
        _onSearchChanged();
      });
    }
  }

  Future<void> _edit(Note note) async {
    final updated = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(existing: note)),
    );
    if (updated != null) {
      setState(() {
        final i = _notes.indexWhere((n) => n.id == updated.id);
        if (i != -1) _notes[i] = updated;
        // Обновляем отфильтрованный список после редактирования
        _onSearchChanged();
      });
    }
  }

  void _delete(Note note) {
    setState(() {
      _notes.removeWhere((n) => n.id == note.id);
      // Обновляем отфильтрованный список после удаления
      _onSearchChanged();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Заметка удалена')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        backgroundColor: const Color.fromARGB(255, 65, 105, 214),
        foregroundColor: Colors.white,
        actions: _buildAppBarActions(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Информация о результатах поиска
          if (_searchController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Найдено заметок: ${_filteredNotes.length}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Список заметок
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_searchController.text.isNotEmpty) ...[
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Заметки не найдены',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Попробуйте изменить запрос поиска',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ] else ...[
                          Icon(Icons.note_add, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Пока нет заметок',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Нажмите + чтобы создать первую заметку',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, i) {
                      final note = _filteredNotes[i];
                      return Dismissible(
                        key: ValueKey(note.id),
                        onDismissed: (DismissDirection direction) {
                          _delete(note);
                        },
                        child: ListTile(
                          key: ValueKey(note.id),
                          title: Text(
                            note.title.isEmpty ? '(без названия)' : note.title,
                          ),
                          subtitle: Text(
                            note.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _edit(note),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(note),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
