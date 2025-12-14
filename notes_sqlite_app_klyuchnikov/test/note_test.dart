import 'package:flutter_test/flutter_test.dart';
import 'package:notes_sqlite_app_klyuchnikov/models/note.dart';

void main() {
  test('Note copyWith updates only passed fields', () {
    final now = DateTime.now();
    final note = Note(
      id: 1,
      title: 'Title',
      body: 'Body',
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
    );

    final updated = note.copyWith(title: 'New title');

    expect(updated.title, 'New title');
    expect(updated.body, 'Body');
    expect(updated.isFavorite, false);
    expect(updated.id, 1);
  });

  test('Note toMap/fromMap roundtrip', () {
    final now = DateTime.now();
    final note = Note(
      id: 10,
      title: 'Test',
      body: 'Text',
      createdAt: now,
      updatedAt: now,
      isFavorite: true,
    );

    final map = note.toMap();
    final restored = Note.fromMap(map);

    expect(restored.title, note.title);
    expect(restored.body, note.body);
    expect(restored.isFavorite, true);
    expect(
      restored.createdAt.millisecondsSinceEpoch,
      now.millisecondsSinceEpoch,
    );
  });

  test('Note.fromMap handles missing nullable fields', () {
    final map = {
      'id': null,
      'title': null,
      'body': null,
      'created_at': 0,
      'updated_at': 0,
      'is_favorite': 0,
    };

    final note = Note.fromMap(map);

    expect(note.title, '');
    expect(note.body, '');
    expect(note.isFavorite, false);
  });
}
