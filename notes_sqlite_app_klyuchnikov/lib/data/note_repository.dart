import '../models/note.dart';

abstract class NoteRepository {
  Future<int> insertNote(Note note);
  Future<List<Note>> fetchNotes();
  Future<List<Note>> searchNotes(String query);
  Future<int> updateNote(Note note);
  Future<int> deleteNote(int id);
  Future<void> toggleFavorite(int id, bool isFavorite);
}
