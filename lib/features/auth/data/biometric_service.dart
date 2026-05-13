// File: lib/features/auth/data/biometric_service.dart
// Purpose: Wrapper around local_auth — only invoked when the user taps the Biometric button.
// Used by: features/auth/presentation/screens/login_screen.dart (and mpin_login in Prompt 4).

import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();
  final LocalAuthentication _auth;

  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
