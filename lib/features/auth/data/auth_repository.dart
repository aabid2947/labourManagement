// File: lib/features/auth/data/auth_repository.dart
// Purpose: Domain-level auth — wraps AuthApiService and persists token via AuthStorage.
// Used by: features/auth/providers/auth_providers.dart.

import '../../../core/storage/auth_storage.dart';
import 'auth_api_service.dart';

class LoginResult {
  const LoginResult({
    required this.token,
    required this.userId,
    required this.role,
    required this.hasMpin,
  });

  final String token;
  final String userId;
  final String role;
  final bool hasMpin;
}

class AuthRepository {
  AuthRepository({AuthApiService? api, AuthStorage? storage})
      : _api = api ?? AuthApiService(),
        _storage = storage ?? AuthStorage();

  final AuthApiService _api;
  final AuthStorage _storage;

  Future<LoginResult> login({
    required String username,
    required String password,
    required String siteId,
  }) async {
    final res = await _api.login(
      username: username,
      password: password,
      siteId: siteId,
    );
    final result = LoginResult(
      token: res['token'] as String,
      userId: res['userId'] as String,
      role: res['role'] as String,
      hasMpin: (res['hasMpin'] as bool?) ?? false,
    );
    // Persist token for later interceptor pickup.
    // TODO(api): once the real /auth/login endpoint is wired, uncomment to persist.
    // await _storage.writeToken(result.token);
    return result;
  }

  Future<bool> contactAdmin({required String name, required String email}) {
    return _api.contactAdmin(name: name, email: email);
  }

  Future<void> logout() async {
    await _storage.clearToken();
  }

  // Reserved for Prompt 4's bootstrap.
  Future<bool> hasMpin() => _storage.hasMpin();
}
