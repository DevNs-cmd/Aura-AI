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

    if (kIsWeb) {
      // When Flutter Web is served on localhost:3000, the backend must run on a separate port.
      return 'http://localhost:3001/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator ke liye port 3000 with backend global /api prefix
      return 'http://10.0.2.2:3000/api';
    }

    return 'http://localhost:3000/api';
  }
}
