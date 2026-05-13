// File: lib/features/profile/data/profile_api_service.dart
// Purpose: Network stubs for the Profile feature.
// Used by: features/profile/data/profile_repository.dart.

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class ProfileApiService {
  ProfileApiService({Dio? dio}) : _dio = dio ?? DioClient().dio;
  final Dio _dio;

  // TODO(api): GET /profile/me — response:
  //   {id, name, role, email, phone, siteName, joinedAt, avatarUrl?}
  Future<Map<String, dynamic>> fetchMe() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return {
      'id': 'SE-4421',
      'name': 'Divya',
      'role': 'Lead Site Engineer',
      'email': 'divya@example.com',
      'phone': '+91 90000 00000',
      'siteName': 'Project Alpha • Mumbai Metro',
      'joinedAt': DateTime(2023, 4, 1).toIso8601String(),
      'avatarUrl': null,
    };
    // Real: return (await _dio.get('/profile/me')).data as Map<String, dynamic>;
  }

  // TODO(api): POST /profile/avatar — request: {image_b64}, response: {avatarUrl}
  Future<String> uploadAvatar({required String imageB64}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'https://files.example.com/avatars/me.jpg';
    // Real: return ((await _dio.post('/profile/avatar', data: {'image_b64': imageB64}))
    //     .data as Map<String, dynamic>)['avatarUrl'] as String;
  }

  // ignore: unused_element
  Dio get _client => _dio;
}
