# Программирование корпоративных систем - практика 10 (11). Работа с базами данных. Основы работы с API (HTTP/REST) для Flutter
## Подготовил Ключников А.Д., ЭФБО-09-23

### Цели работы:
* Понять базовые понятия HTTP/REST: методы, URL/эндпоинты, коды ответов, заголовки, тела запросов/ответов (JSON).
* Освоить основы интеграции Flutter-приложения с внешним API: http/dio, сериализация JSON, обработка ошибок и таймаутов.
* Научиться выстраивать слой данных с репозиторием и отделять его от UI (продолжаем архитектурную линию прошлых ПЗ).
* Реализовать список сущностей из публичного API + экран деталей + форму создания/редактирования (с демонстрацией запросов).
* Разобраться с пагинацией, фильтрацией, аутентификацией (Bearer), ретраями и UX при сетевых сбоях.

### Ход работы:

### Используемый API и эндпоинты

**Вариант B** - Mock API на Express.js с полным CRUD функционалом

<img width="1992" height="599" alt="image" src="https://github.com/user-attachments/assets/2c49ba94-0227-4f4b-98fa-3d38a548eefb" />

<img width="2177" height="540" alt="image" src="https://github.com/user-attachments/assets/33ad2b9b-479d-4eb7-8339-659827123506" />



**Базовый URL**: `http://10.0.2.2:3000` (для Android эмулятора)

**Эндпоинты**:
- `GET /posts` - список заметок с пагинацией (`_page`, `_limit`)
- `GET /posts/:id` - получение конкретной заметки
- `POST /posts` - создание новой заметки
- `PATCH /posts/:id` - обновление заметки
- `DELETE /posts/:id` - удаление заметки

## Архитектура приложения

### Модель данных (lib/models/note.dart)
```dart
class Note {
  final int id;
  final String title;
  final String body;

  Note({required this.id, required this.title, required this.body});

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] is String
        ? int.tryParse(json['id']) ?? 0
        : (json['id'] ?? 0),
    title: json['title'] ?? '',
    body: json['body'] ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body};
}
```
Модель адаптирована для работы с разными типами ID и включает защиту от null значений.

### Репозиторий (lib/data/notes_repository.dart)
```dart
class NotesRepository {
  final ApiClient _client;
  NotesRepository(this._client);

  Future<List<Note>> list({int page = 1, int limit = 20}) async {
    try {
      final resp = await _client.dio.get(
        '/posts',
        queryParameters: {'_page': page, '_limit': limit},
      );
      final data = resp.data as List<dynamic>;
      return data.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Ошибка загрузки списка: ${e.message}');
    }
  }

  Future<Note> get(int id) async {
    try {
      final resp = await _client.dio.get('/posts/$id');
      return Note.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Заметка не найдена');
      }
      throw Exception('Ошибка загрузки: ${e.message}');
    }
  }

  Future<Note> create(String title, String body) async {
    try {
      final resp = await _client.dio.post(
        '/posts',
        data: {'title': title, 'body': body},
      );
      return Note.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Ошибка создания: ${e.message}');
    }
  }

  Future<Note> update(int id, String title, String body) async {
    try {
      final resp = await _client.dio.patch(
        '/posts/$id',
        data: {'title': title, 'body': body},
      );
      return Note.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Ошибка обновления: ${e.message}');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _client.dio.delete('/posts/$id');
    } on DioException catch (e) {
      throw Exception('Ошибка удаления: ${e.message}');
    }
  }
}
```
Репозиторий инкапсулирует всю работу с API, предоставляет чистый интерфейс для UI слоя.

### Ключевые реализации

#### Пагинация
```dart
Future<void> _loadMore() async {
  if (!_canLoadMore || _loading) return;
  setState(() => _loading = true);
  try {
    final batch = await repo.list(page: _page, limit: 20);
    setState(() {
      _items.addAll(batch);
      _applyFilter();
      _canLoadMore = batch.length == 20;
      if (_canLoadMore) _page++;
    });
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
    }
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
```
Бесконечная прокрутка с подгрузкой по 20 элементов, индикатор загрузки внизу списка.

#### Обработка ошибок и таймаутов
```dart
// в lib/data/api_client.dart
factory ApiClient({required String baseUrl}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
}

// в lib/data/notes_repository.dart
try {
  final resp = await _client.dio.get('/posts/$id');
  return Note.fromJson(resp.data);
} on DioException catch (e) {
  throw Exception('Ошибка загрузки: ${e.message}');
}
```

#### UX состояния
- **Loading**: `CircularProgressIndicator` при загрузке и обновлении
- **Empty**: Иконка и текст при отсутствии заметок, кнопка создания
- **Error**: SnackBar с описанием ошибки, возможность повтора
- **Search**: Подсветка результатов, счетчик найденных записей

### Результаты (скриншоты и GIF)

* Скриншот экрана списка (первый экран, данные получены)
<img width="350" alt="Снимок экрана 2025-11-24 190732" src="https://github.com/user-attachments/assets/46fe1b4d-d7ef-4dd4-91c4-d7ce19907731" />

* Скриншот экрана деталей
<img width="350" alt="Снимок экрана 2025-11-24 190804" src="https://github.com/user-attachments/assets/f33692cf-5eba-4366-8548-eae557ea8fc4" />

* Создание заметки (GIF)

![create](https://github.com/user-attachments/assets/fa05f1b3-4628-4290-ac92-0fc7cde0b0ce)

* Редактирование заметки (GIF)

![edit](https://github.com/user-attachments/assets/9df1d1b7-0e7b-402e-89bd-65fd08218f0f)

* Работа поисковой строки (GIF)

![search1](https://github.com/user-attachments/assets/1615a9f8-ec48-49d5-b77d-18ae4df203bc)

* Удаление заметки (GIF)

![delete1](https://github.com/user-attachments/assets/5e0fffec-3f4d-4a07-8d29-9318b0d337ad)


### Вывод

В ходе практической работы было создано приложение, которое демонстрирует полноценную клиент-серверную архитектуру с использованием современных подходов Flutter разработки. Реализован полный CRUD функционал с качественным пользовательским опытом, включая пагинацию, поиск и обработку различных состояний интерфейса. Использование Dio для сетевых запросов обеспечило надежную работу с таймаутами и ошибками. Модульная структура с разделением на репозиторий, модели и UI компоненты позволяет легко масштабировать и поддерживать приложение. Готовое решение может служить шаблоном для создания подобных приложений с сетевым взаимодействием.
