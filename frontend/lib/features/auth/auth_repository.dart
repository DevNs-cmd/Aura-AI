<<<<<<< HEAD
import '../../core/network/api_client.dart';
=======
import 'dart:async';

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_session_store.dart';
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120
import '../../models/user.dart';

abstract class AuthRepository {
  Future<User> signInWithEmailAndPassword(String email, String password);
<<<<<<< HEAD
  Future<User> signUpWithEmailAndPassword(String email, String password, String name);
  Future<void> sendPasswordReset(String email);
=======
  Future<User> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  );
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  Future<void> requestPasswordReset(String email);
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120
  Future<void> signOut();
  Future<User?> getCurrentUser();
}

<<<<<<< HEAD
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);
  final ApiClient _client;
=======
class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({Dio? dio, AuthSessionStore? sessionStore})
    : _sessionStore = sessionStore ?? AuthSessionStore(),
      _dio = dio ?? ApiClient(sessionStore: sessionStore).dio;

  final Dio _dio;
  final AuthSessionStore _sessionStore;
  User? _currentUser;

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final response = await _postAuth('/auth/login', {
      'email': email,
      'password': password,
    });
    return _storeAuthResponse(response);
  }

  @override
  Future<User> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    final response = await _postAuth('/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
    });
    return _storeAuthResponse(response);
  }

  @override
  Future<User> signInWithGoogle() {
    throw UnsupportedError('Social sign-in is not wired to NestJS yet.');
  }

  @override
  Future<User> signInWithApple() {
    throw UnsupportedError('Social sign-in is not wired to NestJS yet.');
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _postAuth('/auth/forgot-password', {'email': email});
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _sessionStore.clearSession();
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    _currentUser = await _sessionStore.readCurrentUser();
    return _currentUser;
  }

  Future<Map<String, dynamic>> _postAuth(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post<dynamic>(path, data: payload);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw const FormatException('Unexpected auth response shape.');
    } on DioException catch (error) {
      throw Exception(_mapAuthError(error));
    }
  }

  Future<User> _storeAuthResponse(Map<String, dynamic> response) async {
    final token = (response['accessToken'] ?? response['access_token'])
        ?.toString();
    final userPayload = response['user'];

    if (token == null || token.isEmpty) {
      throw const FormatException(
        'Auth response did not include an access token.',
      );
    }
    if (userPayload is! Map<String, dynamic>) {
      throw const FormatException(
        'Auth response did not include a user object.',
      );
    }

    final user = User.fromMap(userPayload).copyWith(accessToken: token);
    _currentUser = user;
    await _sessionStore.saveSession(user: user, accessToken: token);
    return user;
  }

  String _mapAuthError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The authentication request timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Unable to reach the authentication server. Check your network connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Invalid email or password.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'The authentication server is unavailable.';
        }
        return _extractServerMessage(error.response?.data) ??
            'Authentication failed.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail != null) {
        return detail.toString();
      }

      final message = data['message'];
      if (message != null) {
        return message.toString();
      }
    }

    return null;
  }
}

class MockAuthRepository implements AuthRepository {
  User? _currentUser;
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120

  Future<User> _authenticate(String path, Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>(path, data: data);
    final payload = response.data!;
    final userData = Map<String, dynamic>.from(payload['user'] as Map);
    final token = payload['accessToken'] as String?;
    if (token == null || token.isEmpty) throw StateError('The server did not return an access token.');
    final user = User.fromMap(userData);
    await _client.saveSession(token, user.toMap());
    return user;
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) =>
      _authenticate('/api/auth/login', {'email': email, 'password': password});

  @override
  Future<User> signUpWithEmailAndPassword(String email, String password, String name) =>
      _authenticate('/api/auth/signup', {'name': name, 'email': email, 'password': password});

  @override
  Future<void> sendPasswordReset(String email) async {
    await _client.post('/api/auth/forgot-password', data: {'email': email});
  }

  @override
<<<<<<< HEAD
  Future<void> signOut() => _client.clearSession();
=======
  Future<User> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    _currentUser = const User(
      id: 'google-user-999',
      email: 'alex.rivera.google@example.com',
      displayName: 'Alex Rivera',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256&h=256&fit=crop',
    );
    return _currentUser!;
  }

  @override
  Future<User> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    _currentUser = const User(
      id: 'apple-user-888',
      email: 'alex.rivera.apple@example.com',
      displayName: 'Alex Rivera',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256&h=256&fit=crop',
    );
    return _currentUser!;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120

  @override
  Future<User?> getCurrentUser() async {
    if (await _client.accessToken() == null) return null;
    final user = await _client.currentUser();
    return user == null ? null : User.fromMap(user);
  }
}
