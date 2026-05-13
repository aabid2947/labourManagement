// File: lib/core/widgets/user_avatar.dart
// Purpose: Reusable circular user avatar. Renders a network photo when a URL is
//          provided, otherwise falls back to a soft-yellow circle with a person
//          glyph. Used by the dashboard top bar, side drawer header, and the
//          Total Labour Strength metric card.
// Used by: dashboard_screen.dart, metric_card.dart (Prompt-3 bug-fix pass).

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.photoUrl,
    this.radius = 18,
    this.iconScale = 1.2,
  });

  /// Backend-supplied URL. When null/empty we render the icon fallback so the
  /// app never ships a flaky placeholder PNG.
  final String? photoUrl;
  final double radius;

  /// Multiplier on the icon size vs. the radius — bumped to ~1.2 so the
  /// person glyph fills the circle the way the Material avatar typically does.
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final hasUrl = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.avatarBg,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasUrl
          ? CachedNetworkImage(
              imageUrl: photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) => _glyph(),
              errorWidget: (_, _, _) => _glyph(),
            )
          : _glyph(),
    );
  }

  Widget _glyph() => Center(
        child: Icon(
          Icons.person,
          color: AppColors.primaryDark,
          size: radius * iconScale,
        ),
      );
}
