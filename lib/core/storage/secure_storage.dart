// File: lib/core/storage/secure_storage.dart
// Purpose: Thin wrapper around flutter_secure_storage to keep call sites uniform.
// Used by: core/storage/auth_storage.dart and any feature that persists secrets.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._internal() : _storage = const FlutterSecureStorage();

  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> clearAll() => _storage.deleteAll();
}
