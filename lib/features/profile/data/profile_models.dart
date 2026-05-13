// File: lib/features/profile/data/profile_models.dart
// Purpose: Typed UserProfile model + display helpers for the Profile screen.
// Used by: profile_api_service, profile_repository, profile_providers, profile_screen.

import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.siteName,
    required this.joinedAt,
    this.avatarUrl,
  });

  /// e.g. `SE-4421` — surfaced as `ID: #SE-4421` on the profile card.
  final String id;
  final String name;
  /// e.g. `Lead Site Engineer`. Server-side enum suggested.
  final String role;
  final String email;
  final String phone;
  final String siteName;
  final DateTime joinedAt;
  final String? avatarUrl;

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        role: j['role'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String,
        siteName: j['siteName'] as String,
        joinedAt: DateTime.parse(j['joinedAt'] as String),
        avatarUrl: j['avatarUrl'] as String?,
      );

  UserProfile copyWith({String? avatarUrl}) => UserProfile(
        id: id,
        name: name,
        role: role,
        email: email,
        phone: phone,
        siteName: siteName,
        joinedAt: joinedAt,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}
