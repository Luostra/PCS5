import 'package:dio/dio.dart';
import '../models/note.dart';
import 'api_client.dart';

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
