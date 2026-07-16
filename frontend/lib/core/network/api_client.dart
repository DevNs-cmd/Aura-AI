import 'package:dio/dio.dart';

import 'api_config.dart';
import 'auth_session_store.dart';

class ApiClient {
  ApiClient({Dio? dio, AuthSessionStore? sessionStore})
      : _sessionStore = sessionStore ?? AuthSessionStore(),
        dio = dio ?? _buildDio() {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStore.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  final AuthSessionStore _sessionStore;

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.nestBaseUrl,
        connectTimeout: ApiConfig.requestTimeout,
        receiveTimeout: ApiConfig.requestTimeout,
        sendTimeout: ApiConfig.requestTimeout,
        headers: const {'Content-Type': 'application/json'},
      ),
    );
  }
}
