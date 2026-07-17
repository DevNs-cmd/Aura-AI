import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _overrideBaseUrl = String.fromEnvironment(
    'AURA_API_BASE_URL',
    defaultValue: '',
  );

  static const bool useMockRepositories = bool.fromEnvironment(
    'AURA_USE_MOCK_REPOS',
    defaultValue: false,
  );

  static const Duration requestTimeout = Duration(seconds: 15);

  static String get nestBaseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator connects to host on port 3001
      return 'http://10.0.2.2:3001/api';
    }

    return 'http://localhost:3001/api';
  }
}
