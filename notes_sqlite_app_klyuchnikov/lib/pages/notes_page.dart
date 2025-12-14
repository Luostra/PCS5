import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/note.dart';
import '../widgets/note_list_item.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DBHelper _dbHelper = DBHelper.instance;
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _dbHelper.fetchNotes();
  }

  void _reloadNotes() {
    setState(() {
      _notesFuture = _dbHelper.fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes SQLite')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(child: Text('Пока нет заметок. Нажмите +'));
          }

          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = notes[index];

              return Dismissible(
                key: ValueKey(note.id),
                background: Container(color: Colors.red.withValues(alpha: 0.2)),
                onDismissed: (_) async {
                  await _dbHelper.deleteNote(note.id!);
                  _reloadNotes();
                },
                child: NoteListItem(
                  note: note,
                  onTap: () => _openEditDialog(context, note: note),
                  onDelete: () async {
                    await _dbHelper.deleteNote(note.id!);
                    _reloadNotes();
                  },
                  onToggleFavorite: () async {
                    await _dbHelper.updateNote(
                      note.copyWith(isFavorite: !note.isFavorite),
                    );
                    _reloadNotes();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openEditDialog(BuildContext context, {Note? note}) {
    showDialog(
      context: context,
      builder: (_) => _EditDialog(
        note: note,
        onSave: (newNote) async {
          if (note == null) {
            await _dbHelper.insertNote(newNote);
          } else {
            await _dbHelper.updateNote(newNote);
          }
          _reloadNotes();
        },
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  final Note? note;
  final ValueChanged<Note> onSave;

  const _EditDialog({this.note, required this.onSave});

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Новая заметка' : 'Редактирование'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Заголовок'),
          ),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(labelText: 'Текст'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final now = DateTime.now();
            widget.onSave(
              Note(
                id: widget.note?.id,
                title: _titleController.text,
                body: _bodyController.text,
                createdAt: widget.note?.createdAt ?? now,
                updatedAt: now,
                isFavorite: widget.note?.isFavorite ?? false,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
