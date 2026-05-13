// File: lib/core/config/env.dart
// Purpose: Build-time environment flags (dev / staging / prod) for the whole app.
// Used by: core/config/api_config.dart, core/network/dio_client.dart

enum Environment { dev, staging, prod }

class Env {
  static const Environment current = Environment.dev;

  static bool get isDev => current == Environment.dev;
  static bool get isProd => current == Environment.prod;
}
