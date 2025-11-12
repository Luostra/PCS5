# Программирование корпоративных систем - практика 9 (10). Работа с базами данных. Подключение к SQLite (Flutter, sqflite)

## Подготовил Ключников А.Д., ЭФБО-09-23

### Цели:

- Подключить Flutter-приложение к локальной базе данных SQLite (пакет sqflite).
- Создать таблицы и реализовать базовый CRUD: добавление, чтение, обновление, удаление.
- Настроить класс-помощник для работы с БД и отделить слой данных от UI.
- Отработать миграции схемы и диагностику частых ошибок.

### Ход работы:

#### 1. Репозиторий и слой данных

Создан абстрактный класс NoteRepository (в файле note_repository.dart) и его реализация DBHelper (класс из файла db_helper.dart, взаимодействующий с базой данных).

Архитектура репозитория:

```dart
abstract class NoteRepository {
  Future<int> insertNote(Note note);
  Future<List<Note>> fetchNotes();
  Future<List<Note>> searchNotes(String query);
  Future<int> updateNote(Note note);
  Future<int> deleteNote(int id);
  Future<void> toggleFavorite(int id, bool isFavorite);
}
```

#### 2. Файл базы данных

- Расположение: файл базы данных notes.db хранится во внутреннем каталоге приложения (в песочнице Android):

```
/data/data/com.example.notes_sqlite_app_klyuchnikov/databases/notes.db
```

- Доступ: защищен песочницей ОС, другие приложения не имеют доступа.

#### 3. Структура таблицы и индексы

##### Таблица notes:

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_favorite INTEGER NOT NULL DEFAULT 0
);
```

##### Созданные индексы:

- idx_notes_created_at - для сортировки по дате создания

- idx_notes_title - для ускорения поиска по заголовку

- idx_notes_favorite - для сортировки по избранному

#### 4. Реализация CRUD операций

##### Create:

- Используется db.insert() с преобразованием Note в Map

- Автоматическая генерация ID через AUTOINCREMENT

- Установка временных меток в миллисекундах

Реализация:

```dart
static Future<int> insertNote(Note note) async {
  final db = await database;
  return await db.insert(notesTable, note.toMap());
}
```

##### Read:

- fetchNotes() - получение всех заметок с сортировкой

- searchNotes() - поиск по заголовку с использованием LIKE

- Преобразование Map в объекты Note через fromMap()

Реализация:

```dart
static Future<List<Note>> fetchNotes() async {
  final db = await database;
  final rows = await db.query(notesTable,
      orderBy: 'is_favorite DESC, created_at DESC');
  return rows.map((m) => Note.fromMap(m)).toList();
}

static Future<List<Note>> searchNotes(String query) async {
  final db = await database;
  final rows = await db.query(
    notesTable,
    where: 'title LIKE ?',
    whereArgs: ['%$query%'],
    orderBy: 'is_favorite DESC, created_at DESC',
  );
  return rows.map((m) => Note.fromMap(m)).toList();
}
```

##### Update:

- updateNote() - обновление по ID

- toggleFavorite() - специализированный метод для избранного

- Автоматическое обновление updated_at

Реализация:

```dart
static Future<int> updateNote(Note note) async {
  final db = await database;
  return await db.update(
    notesTable,
    note.toMap(),
    where: 'id = ?',
    whereArgs: [note.id],
  );
}
```

##### Delete:

- deleteNote() - удаление по ID

- Поддержка свайпа в UI для удобного удаления

Реализация:

```dart
static Future<int> deleteNote(int id) async {
  final db = await database;
  return await db.delete(notesTable, where: 'id = ?', whereArgs: [id]);
}
```

##### 5. Оптимизация

- Индексы: cозданы для всех полей, используемых в WHERE и ORDER BY

- Сортировка: приоритет избранных заметок, затем по дате создания

### Результаты:

- Скриншот приложения с пустым списком (первый запуск)

- Скриншот после добавления заметки

- Скриншот окна редактирования и итоговой записи

- Скриншот после удаления (запись исчезла)

- Работа поисковой строки (GIF)

- Скриншот тестирования

### Вывод:

В ходе практической работы было успешно разработано Flutter-приложение для управления заметками с использованием локальной базы данных SQLite. Реализован полный цикл CRUD-операций, система миграций схемы БД и поиск по содержимому с оптимизацией через индексы. Приложение демонстрирует чистую архитектуру с разделением на репозиторий, модели и UI-слой, что обеспечивает тестируемость и поддерживаемость кода.
