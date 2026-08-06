import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/auth_repository.dart';

enum LoginStatus { idle, sending, sent, error }

class LoginState {
  const LoginState({
    this.status = LoginStatus.idle,
    this.mobileNumber,
    this.expiresInSeconds,
    this.errorMessage,
  });

  final LoginStatus status;
  final String? mobileNumber;
  final int? expiresInSeconds;
  final String? errorMessage;

  bool get isSending => status == LoginStatus.sending;

  LoginState copyWith({
    LoginStatus? status,
    String? mobileNumber,
    int? expiresInSeconds,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      expiresInSeconds: expiresInSeconds ?? this.expiresInSeconds,
      errorMessage: errorMessage,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<bool> sendOtp(String mobileNumber) async {
    if (state.isSending) return false; // guard against double-tap races

    state = state.copyWith(
      status: LoginStatus.sending,
      mobileNumber: mobileNumber,
      errorMessage: null,
    );

    final result = await ref.read(authRepositoryProvider).sendOtp(mobileNumber);

    return result.when(
      success: (data) {
        state = state.copyWith(
          status: LoginStatus.sent,
          expiresInSeconds: data.expiresInSeconds,
        );
        return true;
      },
      failure: (exception) {
        state = state.copyWith(status: LoginStatus.error, errorMessage: exception.message);
        return false;
      },
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(status: LoginStatus.idle, errorMessage: null);
    }
  }
}

final loginProvider = NotifierProvider.autoDispose<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
