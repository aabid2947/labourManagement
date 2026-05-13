// File: lib/features/auth/data/auth_api_service.dart
// Purpose: Network calls for auth — login + contact-admin. All endpoints are stubs.
// Used by: features/auth/data/auth_repository.dart.

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class AuthApiService {
  AuthApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;
  final Dio _dio;

  // TODO(api): POST /auth/login — request: {username, password, siteId},
  // response: {token, userId, role, hasMpin: bool}
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String siteId,
  }) async {
    // Backend dev will replace this body with a real call. Left as a deterministic
    // mock so the frontend flow can be exercised end-to-end.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return {
      'token': 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
      'userId': 'mock-user',
      'role': 'site_engineer',
      'hasMpin': false,
    };
    // Real implementation:
    // final res = await _dio.post('/auth/login', data: {
    //   'username': username,
    //   'password': password,
    //   'siteId': siteId,
    // });
    // return res.data as Map<String, dynamic>;
  }

  // TODO(api): POST /contact-admin — request: {name, email}, response: {success: bool}
  Future<bool> contactAdmin({required String name, required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return true;
    // Real implementation:
    // final res = await _dio.post('/contact-admin', data: {
    //   'name': name,
    //   'email': email,
    // });
    // return (res.data as Map<String, dynamic>)['success'] == true;
  }

  // Silences "unused field" until real endpoints land.
  // ignore: unused_element
  Dio get _client => _dio;
}
