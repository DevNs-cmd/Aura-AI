import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashState {
  final bool isInitialized;
  final String? errorMessage;

  SplashState({this.isInitialized = false, this.errorMessage});

  SplashState copyWith({bool? isInitialized, String? errorMessage}) {
    return SplashState(
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SplashController extends AutoDisposeNotifier<SplashState> {
  @override
  SplashState build() {
    _initialize();
    return SplashState();
  }

  Future<void> _initialize() async {
    try {
      // Simulate app initialization steps:
      // - Load local settings/theme configuration
      // - Initialize database (SQLite/Hive/SharedPreferences)
      // - Check for existing session tokens
      await Future.delayed(const Duration(milliseconds: 3000));

      if (state.errorMessage == null) {
        state = state.copyWith(isInitialized: true);
      }
    } catch (e) {
      state = state.copyWith(isInitialized: false, errorMessage: e.toString());
    }
  }
}

final splashControllerProvider =
    AutoDisposeNotifierProvider<SplashController, SplashState>(() {
      return SplashController();
    });
