import 'dart:async';
import '../../models/user.dart';

abstract class AuthRepository {
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  );
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  Future<void> signOut();
  Future<User?> getCurrentUser();
}

class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Simulated loading state

    if (email == 'error@example.com') {
      throw Exception('Invalid credentials. Please try again.');
    }

    _currentUser = User(
      id: 'mock-user-123',
      email: email,
      displayName: 'Alex Rivera',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256&h=256&fit=crop',
    );

    return _currentUser!;
  }

  @override
  Future<User> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Simulated loading state

    if (email.contains('taken')) {
      throw Exception('This email address is already in use.');
    }

    _currentUser = User(
      id: 'mock-user-123',
      email: email,
      displayName: name.isNotEmpty ? name : 'Alex Rivera',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256&h=256&fit=crop',
    );

    return _currentUser!;
  }

  @override
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
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }
}
