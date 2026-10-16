import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:swarna_bindu/core/network/api_endpoints.dart';

import '../../data/models/profile_response_model.dart';
import '../../data/repository/profile_repository.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.data,
    this.errorMessage,
    this.isRefreshing = false,
  });

  final ProfileStatus status;
  final ProfileData? data;
  final String? errorMessage;
  final bool isRefreshing;

  bool get isLoading => status == ProfileStatus.loading;
  bool get isError => status == ProfileStatus.error;
  bool get hasData => data != null;

  // ── Derived values the screen binds to ──────────────────────────
  String get name {
    final n = data?.profile.personalInfo.fullName;
    return (n == null || n.isEmpty) ? '—' : n;
  }

  /// `+919876543210` → `+91 98765 43210` (other shapes are shown as-is).
  String get mobile {
    final raw = data?.profile.mobileNumber ?? '';
    if (raw.isEmpty) return '—';
    final m = RegExp(r'^\+91(\d{5})(\d{5})$').firstMatch(raw);
    return m == null ? raw : '+91 ${m.group(1)} ${m.group(2)}';
  }

  /// Absolute URL for the avatar, or null. Handles both absolute (CDN) and
  /// relative paths.
  String? get profilePictureUrl {
    final p = data?.profile.personalInfo.profilePicture;
    if (p == null || p.isEmpty) return null;
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final origin = Uri.parse(EnvConfig.baseUrl).origin;
    return p.startsWith('/') ? '$origin$p' : '$origin/$p';
  }

  String get kycStatus => data?.profile.kycStatus ?? '';
  bool get isKycApproved => data?.profile.isKycApproved ?? false;

  double get totalInvestment => data?.investments.totalSavingsValue ?? 0;
  double get currentValue => data?.investments.currentGoldValue ?? 0;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileData? data,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return ProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      // Cleared unless set explicitly (same convention as DashboardState).
      errorMessage: errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(status: ProfileStatus.loading);
    await _fetch();
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true);
    await _fetch();
  }

  Future<void> _fetch() async {
    final result = await ref.read(profileRepositoryProvider).getProfile();
    if (!ref.mounted) return;

    result.when(
      success: (data) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          data: data,
          isRefreshing: false,
        );
      },
      failure: (e) {
        // Keep stale data on screen if we have any; only go to the error
        // state when there is nothing to show.
        state = state.copyWith(
          status: state.hasData ? ProfileStatus.loaded : ProfileStatus.error,
          errorMessage: e.message,
          isRefreshing: false,
        );
      },
    );
  }
}

final profileProvider = NotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);