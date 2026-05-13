// File: lib/core/config/api_config.dart
// Purpose: API base URL + timeouts. Real endpoints will be wired during backend integration.
// Used by: core/network/dio_client.dart and every feature api_service.

import 'env.dart';

class ApiConfig {
  // TODO(api): replace with real base URLs before backend integration.
  static const String _devBaseUrl = 'https://dev.api.placeholder.local';
  static const String _stagingBaseUrl = 'https://staging.api.placeholder.local';
  static const String _prodBaseUrl = 'https://api.placeholder.local';

  static String get baseUrl {
    switch (Env.current) {
      case Environment.dev:
        return _devBaseUrl;
      case Environment.staging:
        return _stagingBaseUrl;
      case Environment.prod:
        return _prodBaseUrl;
    }
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
