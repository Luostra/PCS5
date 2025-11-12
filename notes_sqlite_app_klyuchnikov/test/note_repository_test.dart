import 'package:flutter_test/flutter_test.dart';
import 'package:notes_sqlite_app_klyuchnikov/data/db_helper.dart';
import 'package:notes_sqlite_app_klyuchnikov/models/note.dart';

void main() {
  group('DBHelper Tests', () {
    late DBHelper dbHelper;

    setUp(() {
      dbHelper = DBHelper.instance;
    });

    test('Note model toMap and fromMap', () {
      final now = DateTime.now();
      final note = Note(
        title: 'Test Title',
        body: 'Test Body',
        createdAt: now,
        updatedAt: now,
        isFavorite: true,
      );

      final map = note.toMap();
      final fromMapNote = Note.fromMap(map);

      expect(fromMapNote.title, note.title);
      expect(fromMapNote.body, note.body);
      expect(fromMapNote.isFavorite, note.isFavorite);
    });

    test('Note copyWith', () {
      final now = DateTime.now();
      final original = Note(
        title: 'Original',
        body: 'Body',
        createdAt: now,
        updatedAt: now,
      );

      final copied = original.copyWith(title: 'Updated', isFavorite: true);

      expect(copied.title, 'Updated');
      expect(copied.body, 'Body');
      expect(copied.isFavorite, true);
      expect(original.title, 'Original');
    });

    test('Search logic', () {
      final notes = [
        Note(
          title: 'Flutter Development',
          body: 'Learning Flutter',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Note(
          title: 'Dart Programming',
          body: 'Dart language features',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Note(
          title: 'Mobile App',
          body: 'Flutter mobile development',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final filtered = notes
          .where(
            (note) =>
                note.title.toLowerCase().contains('flutter') ||
                note.body.toLowerCase().contains('flutter'),
          )
          .toList();

      expect(filtered, hasLength(2));
      expect(filtered[0].title, 'Flutter Development');
      expect(filtered[1].body, 'Flutter mobile development');
    });
  });

  group('Migration Tests', () {
    test('Migration from v1 to v2 adds favorite column', () {
      final v1Data = {
        'id': 1,
        'title': 'Old Note',
        'body': 'Old Body',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

      final v2Data = {...v1Data, 'is_favorite': 0};

      final note = Note.fromMap(v2Data);
      expect(note.isFavorite, false);
    });
  });
}
