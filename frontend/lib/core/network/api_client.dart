import 'package:dio/dio.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _apiBaseUrl = "http://localhost:8000";
const _accessTokenKey = 'access_token';

class ApiClient {
  ApiClient._(this._dio);
  final Dio _dio;

  static Future<ApiClient> create() async {
    final dio = Dio(BaseOptions(baseUrl: _apiBaseUrl));
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_accessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
    return ApiClient._(dio);
  }

  // YE METHODS YAHAN RAHEGI
  Future<Response<T>> patch<T>(String path, {Object? data}) => _dio.patch<T>(path, data: data);
  Future<Response<T>> get<T>(String path) => _dio.get<T>(path);
  Future<Response<T>> post<T>(String path, {Object? data}) => _dio.post<T>(path, data: data);
}

// PROVIDER KO CLASS KE BAHAR LIKHO (Yahan se error hat jayega)
final apiClientProvider = FutureProvider<ApiClient>((ref) => ApiClient.create());
=======

import 'api_config.dart';
import 'auth_session_store.dart';

class ApiClient {
  ApiClient({Dio? dio, AuthSessionStore? sessionStore})
      : _sessionStore = sessionStore ?? AuthSessionStore(),
        dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.nestBaseUrl,
                connectTimeout: ApiConfig.requestTimeout,
                receiveTimeout: ApiConfig.requestTimeout,
                sendTimeout: ApiConfig.requestTimeout,
                headers: const {'Content-Type': 'application/json'},
              ),
            ) {
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
}
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120
