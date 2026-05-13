// File: lib/features/auth/providers/auth_providers.dart
// Purpose: Riverpod providers for auth — repository, biometric service, login controller.
// Used by: login_screen.dart, contact_admin_screen.dart, mpin screens (Prompt 4).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/biometric_service.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final biometricServiceProvider =
    Provider<BiometricService>((ref) => BiometricService());

class LoginState {
  const LoginState({this.loading = false, this.error});
  final bool loading;
  final String? error;

  LoginState copyWith({bool? loading, String? error, bool clearError = false}) {
    return LoginState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<LoginResult?> login({
    required String username,
    required String password,
    required String siteId,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(
        username: username,
        password: password,
        siteId: siteId,
      );
      state = state.copyWith(loading: false);
      return result;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }
}

final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);
