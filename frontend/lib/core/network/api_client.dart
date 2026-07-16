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
        onError: (error, handler) async {
          // Only clear the session when NestJS auth routes reject the token.
          // FastAPI routes (e.g. /api/v1/*) returning 401 should NOT wipe the
          // session — the token is still valid for NestJS; FastAPI was just
          // rejecting it due to a configuration mismatch (now fixed).
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            final isNestAuthRoute = !path.contains('/api/v1/');
            if (isNestAuthRoute) {
              await _sessionStore.clearSession();
            }
          }
          handler.next(error);
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
