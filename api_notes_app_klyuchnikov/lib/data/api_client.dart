import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  factory ApiClient({required String baseUrl, String? bearerToken}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('→ ${options.method} ${options.uri}');
          handler.next(options);
        },
        onError: (e, handler) {
          print('← ERROR: ${e.type} ${e.message}');
          handler.next(e);
        },
        onResponse: (response, handler) {
          print('← ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
      ),
    );
    return ApiClient._(dio);
  }
}
