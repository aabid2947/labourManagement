// File: lib/core/storage/auth_storage.dart
// Purpose: Persistence for auth token + hashed MPIN. Wraps SecureStorage with typed keys.
// Used by: features/auth (Prompts 3 + 4) and core/network/api_interceptor.dart.

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'secure_storage.dart';

class AuthStorage {
  AuthStorage._internal();
  static final AuthStorage _instance = AuthStorage._internal();
  factory AuthStorage() => _instance;

  static const _tokenKey = 'auth_token';
  static const _mpinKey = 'mpin_hash';
  // Per-install salt — keeps two devices with the same MPIN from producing the same hash.
  static const _mpinSalt = 'labour_mgmt_v1::';

  final SecureStorage _storage = SecureStorage();

  Future<String?> readToken() => _storage.read(_tokenKey);
  Future<void> writeToken(String token) => _storage.write(_tokenKey, token);
  Future<void> clearToken() => _storage.delete(_tokenKey);

  // MPIN never leaves the device in plaintext — we store sha256(salt + mpin).
  String _hash(String mpin) =>
      sha256.convert(utf8.encode('$_mpinSalt$mpin')).toString();

  Future<void> writeMpin(String mpin) =>
      _storage.write(_mpinKey, _hash(mpin));

  Future<bool> verifyMpin(String mpin) async {
    final stored = await _storage.read(_mpinKey);
    if (stored == null) return false;
    return stored == _hash(mpin);
  }

  Future<bool> hasMpin() async => (await _storage.read(_mpinKey)) != null;
  Future<void> clearMpin() => _storage.delete(_mpinKey);
}
