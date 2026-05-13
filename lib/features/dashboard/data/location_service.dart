// File: lib/features/dashboard/data/location_service.dart
// Purpose: Wrapper around geolocator — request permission once, return current coords.
//          Real reverse-geocoding to a human-readable address is left for backend or a
//          future package; for now we return coords as text.
// Used by: features/dashboard/providers/dashboard_providers.dart.

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns a non-null string ONLY when permission was granted and a fix was obtained.
  /// Quietly returns null otherwise so the UI can fall back to the site name alone.
  Future<String?> getCurrentLocationLabel() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      // TODO(api): when backend exposes /reverse-geocode, replace this with the resolved
      //            human-readable address (e.g. "Mumbai Metro").
      return '${pos.latitude.toStringAsFixed(3)}, ${pos.longitude.toStringAsFixed(3)}';
    } catch (_) {
      return null;
    }
  }
}
