import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_config.dart';
import '../../models/user.dart';
import 'auth_repository.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
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
    User? user,
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

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
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
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final user = await _repository.signInWithEmailAndPassword(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signUp(String email, String password, [dynamic extraName, dynamic optionalArg]) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final nameInput = (extraName is String) ? extraName : '';
      final user = await _repository.signUpWithEmailAndPassword(
        email,
        password,
        nameInput,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await requestPasswordReset(email);
  }

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

  Future<void> signOut() async {
    await _repository.signOut();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final user = await _repository.signInWithGoogle();
      state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final user = await _repository.signInWithApple();
      state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ApiConfig.useMockRepositories) {
    return MockAuthRepository();
  }
  return HttpAuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});