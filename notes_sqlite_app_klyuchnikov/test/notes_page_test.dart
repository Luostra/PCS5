import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_sqlite_app_klyuchnikov/pages/notes_page.dart';

void main() {
  testWidgets('NotesPage renders title and FAB', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotesPage()));

    // Первый кадр
    await tester.pump();

    expect(find.text('Notes SQLite'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('FAB opens create note dialog', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotesPage()));

    // Даём отрендериться первому кадру
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));

    // Один кадр на открытие диалога
    await tester.pump();

    expect(find.text('Новая заметка'), findsOneWidget);
    expect(find.text('Сохранить'), findsOneWidget);
    expect(find.text('Отмена'), findsOneWidget);
  });

  testWidgets('Loading indicator is shown initially', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotesPage()));

    // Пока Future не завершён — показывается loader
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
