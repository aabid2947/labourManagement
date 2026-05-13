// File: lib/features/profile/providers/profile_providers.dart
// Purpose: Riverpod providers for the Profile feature.
// Used by: profile_screen.dart.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_models.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider =
    Provider<ProfileRepository>((_) => ProfileRepository());

/// Regular (non-autoDispose) FutureProvider so bouncing in and out of the
/// Profile screen doesn't re-fetch on every visit.
final profileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(profileRepositoryProvider).fetchMe();
});
