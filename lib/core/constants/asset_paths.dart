// File: lib/core/constants/asset_paths.dart
// Purpose: Single source for image / icon / font asset paths.
// Used by: widgets and screens that load bundled assets.

class AssetPaths {
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  /// TEJ Group brand mark — used on splash + BrandHeader (auth screens).
  static const String tejGroupLogo = '$_images/tej_group_logo.png';

  /// 1024px square — consumed by flutter_launcher_icons at build time only.
  /// Declared here for discoverability; never imported from Dart code.
  // ignore: unused_field
  static const String _launcherIcon = '$_icons/launcher_icon.png';

  static const String placeholderUser = '$_images/placeholder_user.png';
}
