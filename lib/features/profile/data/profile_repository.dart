// File: lib/features/profile/data/profile_repository.dart
// Purpose: Domain wrapper for ProfileApiService — typed UserProfile.
// Used by: features/profile/providers/profile_providers.dart.

import 'profile_api_service.dart';
import 'profile_models.dart';

class ProfileRepository {
  ProfileRepository({ProfileApiService? api})
      : _api = api ?? ProfileApiService();
  final ProfileApiService _api;

  Future<UserProfile> fetchMe() async {
    final j = await _api.fetchMe();
    return UserProfile.fromJson(j);
  }

  Future<String> uploadAvatar({required String imageB64}) =>
      _api.uploadAvatar(imageB64: imageB64);
}
