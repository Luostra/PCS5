import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';
import 'note_repository.dart';

class DBHelper implements NoteRepository {
  static const _dbName = 'app.db';
  static const _dbVersion = 2;
  static Database? _db;

  static const notesTable = 'notes';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final docs = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docs.path, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $notesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_notes_created_at ON $notesTable(created_at DESC);',
    );
    await db.execute('CREATE INDEX idx_notes_title ON $notesTable(title);');
    await db.execute(
      'CREATE INDEX idx_notes_favorite ON $notesTable(is_favorite);',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $notesTable ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0;',
      );
      await db.execute(
        'CREATE INDEX idx_notes_favorite ON $notesTable(is_favorite);',
      );
    }
  }

  @override
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(
      notesTable,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<List<Note>> fetchNotes() async {
    final db = await database;
    final rows = await db.query(
      notesTable,
      orderBy: 'is_favorite DESC, created_at DESC',
    );
    return rows.map((m) => Note.fromMap(m)).toList();
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    if (query.isEmpty) return fetchNotes();

    final db = await database;
    final rows = await db.query(
      notesTable,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'is_favorite DESC, created_at DESC',
    );
    return rows.map((m) => Note.fromMap(m)).toList();
  }

  @override
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(notesTable, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      notesTable,
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
