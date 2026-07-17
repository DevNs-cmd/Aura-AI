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
      // Flutter Web served alongside NestJS on port 3001
      return 'http://localhost:3001/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Real Android device needs the LAN IP of the dev machine.
      // NestJS is on port 3001 (confirmed via netstat).
      return 'http://192.168.29.237:3001/api';
    }

    // iOS simulator / desktop
    return 'http://localhost:3001/api';
  }

  /// FastAPI (Python) backend — handles document upload + RAG indexing.
  static String get fastapiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8002/api/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Use 10.0.2.2 for emulator, real device needs the LAN IP of the dev machine.
      return 'http://192.168.29.237:8002/api/v1';
    }
    // iOS simulator / desktop — localhost works fine.
    return 'http://localhost:8002/api/v1';
  }

  static String get aiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8002/ai';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Use LAN IP of the machine
      return 'http://192.168.29.237:8002/ai';
    }
    return 'http://localhost:8002/ai';
  }
}
