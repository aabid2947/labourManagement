// File: lib/features/auth/providers/mpin_providers.dart
// Purpose: Riverpod controllers for Set / Confirm MPIN flow and MPIN Login lockout state.
// Used by: set_mpin_screen.dart, confirm_mpin_screen.dart, mpin_login_screen.dart.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/auth_storage.dart';

const int mpinLength = 4;
const int mpinMaxAttempts = 5;
const Duration mpinLockDuration = Duration(seconds: 30);

/// Holds the MPIN entered on the Set screen so the Confirm screen can compare.
class MpinDraft {
  MpinDraft(this.value);
  final String value;
}

class MpinDraftController extends Notifier<MpinDraft?> {
  @override
  MpinDraft? build() => null;
  void set(String value) => state = MpinDraft(value);
  void clear() => state = null;
}

final mpinDraftProvider =
    NotifierProvider<MpinDraftController, MpinDraft?>(MpinDraftController.new);

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

class MpinLoginState {
  const MpinLoginState({
    this.entered = '',
    this.attemptsLeft = mpinMaxAttempts,
    this.error,
    this.lockedUntil,
    this.verifying = false,
  });

  final String entered;
  final int attemptsLeft;
  final String? error;
  final DateTime? lockedUntil;
  final bool verifying;

  bool get isLocked =>
      lockedUntil != null && DateTime.now().isBefore(lockedUntil!);

  int get secondsRemaining {
    if (lockedUntil == null) return 0;
    final diff = lockedUntil!.difference(DateTime.now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  MpinLoginState copyWith({
    String? entered,
    int? attemptsLeft,
    String? error,
    DateTime? lockedUntil,
    bool? verifying,
    bool clearError = false,
    bool clearLock = false,
  }) {
    return MpinLoginState(
      entered: entered ?? this.entered,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      error: clearError ? null : (error ?? this.error),
      lockedUntil: clearLock ? null : (lockedUntil ?? this.lockedUntil),
      verifying: verifying ?? this.verifying,
    );
  }
}

class MpinLoginController extends Notifier<MpinLoginState> {
  Timer? _tick;

  @override
  MpinLoginState build() {
    ref.onDispose(() => _tick?.cancel());
    return const MpinLoginState();
  }

  void appendDigit(int d) {
    if (state.isLocked || state.verifying) return;
    if (state.entered.length >= mpinLength) return;
    state = state.copyWith(
      entered: state.entered + d.toString(),
      clearError: true,
    );
  }

  void backspace() {
    if (state.isLocked || state.verifying) return;
    if (state.entered.isEmpty) return;
    state = state.copyWith(
      entered: state.entered.substring(0, state.entered.length - 1),
      clearError: true,
    );
  }

  void resetEntered() {
    state = state.copyWith(entered: '', clearError: true);
  }

  /// Returns true on a successful match. Side-effects: clears entered + advances attempts.
  Future<bool> verify() async {
    if (state.entered.length != mpinLength || state.isLocked) return false;
    state = state.copyWith(verifying: true);
    final ok = await ref.read(authStorageProvider).verifyMpin(state.entered);
    if (ok) {
      state = const MpinLoginState();
      return true;
    }
    final remaining = state.attemptsLeft - 1;
    if (remaining <= 0) {
      final until = DateTime.now().add(mpinLockDuration);
      state = state.copyWith(
        entered: '',
        attemptsLeft: 0,
        error: 'Too many attempts. Try again in 30s.',
        lockedUntil: until,
        verifying: false,
      );
      _startLockTick();
    } else {
      state = state.copyWith(
        entered: '',
        attemptsLeft: remaining,
        error: 'Incorrect MPIN. $remaining attempts left.',
        verifying: false,
      );
    }
    return false;
  }

  void _startLockTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!state.isLocked) {
        t.cancel();
        state = state.copyWith(
          attemptsLeft: mpinMaxAttempts,
          clearError: true,
          clearLock: true,
        );
      } else {
        // Force a re-emit so UI can refresh the countdown.
        state = state.copyWith();
      }
    });
  }
}

final mpinLoginControllerProvider =
    NotifierProvider<MpinLoginController, MpinLoginState>(
        MpinLoginController.new);

/// Decides the post-splash starting route.
enum AuthBootstrapDecision { mpinLogin, login }

final authBootstrapProvider = FutureProvider<AuthBootstrapDecision>((ref) async {
  final hasMpin = await ref.read(authStorageProvider).hasMpin();
  return hasMpin ? AuthBootstrapDecision.mpinLogin : AuthBootstrapDecision.login;
});
