import '../../core/network/api_client.dart';
import '../../models/user.dart';

abstract class AuthRepository {
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> signUpWithEmailAndPassword(String email, String password, String name);
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Future<User?> getCurrentUser();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);
  final ApiClient _client;

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
  Future<void> signOut() => _client.clearSession();

  @override
  Future<User?> getCurrentUser() async {
    if (await _client.accessToken() == null) return null;
    final user = await _client.currentUser();
    return user == null ? null : User.fromMap(user);
  }
}
