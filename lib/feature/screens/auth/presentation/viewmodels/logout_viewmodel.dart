import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:swarna_bindu/core/storage/secure_storage_service.dart';

import '../../data/repository/auth_repository.dart';

enum LogoutStatus { idle, loading, done }

class LogoutState {
  const LogoutState({
    this.status = LogoutStatus.idle,
    this.serverCallFailed = false,
  });

  final LogoutStatus status;

  /// True if the local session was cleared but the `/auth/logout` network
  /// call itself failed (offline, timeout, server error) — the user is
  /// still logged out locally, this is just informational for a snackbar.
  final bool serverCallFailed;

  bool get isLoading => status == LogoutStatus.loading;

  LogoutState copyWith({LogoutStatus? status, bool? serverCallFailed}) {
    return LogoutState(
      status: status ?? this.status,
      serverCallFailed: serverCallFailed ?? this.serverCallFailed,
    );
  }
}

/// Owns only the logout action. Deliberately not folded into a broader
/// AuthNotifier since none exists yet for login/OTP (those screens read
/// AuthRepository directly per the current codebase) — this stays scoped
/// to avoid guessing at that structure.
class LogoutNotifier extends Notifier<LogoutState> {
  @override
  LogoutState build() => const LogoutState();

  /// Always clears the local session (secure storage), even if the server
  /// call fails — the user expects "Log Out" to work instantly and
  /// locally regardless of connectivity. The refresh token becoming
  /// invalid server-side is a nice-to-have, not a precondition for the
  /// local logout to take effect.
  Future<void> logout() async {
    if (state.isLoading) return;
    state = state.copyWith(status: LogoutStatus.loading);

    final storage = ref.read(secureStorageProvider);
    final refreshToken = await storage.refreshToken;

    bool serverCallFailed = false;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      final result = await ref.read(authRepositoryProvider).logout(refreshToken);
      result.when(
        success: (_) {},
        failure: (_) => serverCallFailed = true,
      );
    }

    await storage.clearAll();

    state = state.copyWith(
      status: LogoutStatus.done,
      serverCallFailed: serverCallFailed,
    );
  }
}

final logoutProvider = NotifierProvider.autoDispose<LogoutNotifier, LogoutState>(
  LogoutNotifier.new,
);