import 'package:flutter_test/flutter_test.dart';
import 'package:notes_sqlite_app_klyuchnikov/models/note.dart';
import 'package:notes_sqlite_app_klyuchnikov/data/note_repository.dart';

class FakeNoteRepository implements NoteRepository {
  final List<Note> _notes = [];

  @override
  Future<int> insertNote(Note note) async {
    _notes.add(note);
    return _notes.length;
  }

  @override
  Future<List<Note>> fetchNotes() async {
    return List.of(_notes);
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    return _notes
        .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<int> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
    return 1;
  }

  @override
  Future<int> deleteNote(int id) async {
    _notes.removeWhere((n) => n.id == id);
    return 1;
  }

  @override
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isFavorite: isFavorite);
    }
  }
}

void main() {
  test('Repository inserts and fetches notes', () async {
    final repo = FakeNoteRepository();

    await repo.insertNote(
      Note(
        id: 1,
        title: 'Hello',
        body: 'World',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final notes = await repo.fetchNotes();
    expect(notes.length, 1);
  });

  test('Search returns matching notes', () async {
    final repo = FakeNoteRepository();

    await repo.insertNote(
      Note(
        id: 1,
        title: 'Flutter',
        body: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final result = await repo.searchNotes('flutter');
    expect(result.length, 1);
  });
}
