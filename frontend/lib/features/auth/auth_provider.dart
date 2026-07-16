import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
=======
import '../../core/network/api_config.dart';
import '../../models/user.dart';
import 'auth_repository.dart';
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120

// ==========================================================================
// 1. AUTH STATUS
// ==========================================================================
enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

// ==========================================================================
// 2. USER MODEL (Dynamic handling ke liye ekdum mast object)
// ==========================================================================
class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  // Backend json response parse karne ke liye
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

// ==========================================================================
// 3. AUTH STATE
// ==========================================================================
class AuthState {
  final AuthStatus status;
  final UserModel? user; 
  final String? errorMessage;
  final bool rememberMe;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.rememberMe = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? rememberMe,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

<<<<<<< HEAD
// ==========================================================================
// 4. AUTH REPOSITORY (Actual Logic Layer - Placeholder to Real Backend Flow)
// ==========================================================================
class AuthRepository {
  // Yahan apna backend endpoint connect kar sakte ho baad mein
  Future<UserModel> login(String email, String password) async {
    // Fake intentional delay to simulate network call
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Fallback Mock Response: Agar backend abhi offline hai toh email se naam nikalega
    String extractedName = email.split('@')[0].replaceAll('.', ' ').replaceAll('_', ' ');
    String formattedName = extractedName.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' ');
=======
// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ApiConfig.useMockRepositories) {
    return MockAuthRepository();
  }

  return HttpAuthRepository();
});
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120

    return UserModel(id: 'usr_123', name: formattedName, email: email);
  }

  Future<UserModel> register(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return UserModel(id: 'usr_456', name: name.isEmpty ? 'New User' : name, email: email);
  }
}

// ==========================================================================
// 5. AUTH NOTIFIER (Saari UI Screens ko handle karne wala Controller)
// ==========================================================================
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
<<<<<<< HEAD
    _restoreSession();
=======
    unawaited(_restoreSession());
  }

  Future<void> _restoreSession() async {
    final currentUser = await _repository.getCurrentUser();
    if (!mounted || currentUser == null) {
      return;
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: currentUser,
      errorMessage: null,
    );
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120
  }

  Future<void> _restoreSession() async {
    // Background auto-login initialization
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  // 🔐 SIGN IN (Screens calls this)
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  // 📝 SIGN UP (Handles extra positional arguments safely)
  Future<void> signUp(String email, String password, [dynamic extraName, dynamic optionalArg]) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      // Screen agar name parameter bhej rahi hai toh extraName ko cast karenge string mein
      String nameInput = (extraName != null && extraName is String) ? extraName : '';
      
      final user = await _repository.register(email, password, nameInput);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  // 🔄 PASSWORD RESET
  Future<void> sendPasswordReset(String email) async {
    // Future expansion logic
  }

<<<<<<< HEAD
  // 🚪 SIGN OUT
=======
  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      await _repository.requestPasswordReset(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120
  Future<void> signOut() async {
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  // 🌐 GOOGLE SIGN-IN PLACEHOLDER
  Future<void> signInWithGoogle() async {}

  // 🍏 APPLE SIGN-IN PLACEHOLDER
  Future<void> signInWithApple() async {}
}

// ==========================================================================
// 6. RIVERPOD PROVIDERS (Global accessors)
// ==========================================================================
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});