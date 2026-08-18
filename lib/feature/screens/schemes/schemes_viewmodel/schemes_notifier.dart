import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarna_bindu/core/network/api_exceptions.dart';

import '../data/models/scheme_response_model.dart';
import '../data/repository/schemes_repository.dart';
import 'scheme_model.dart';


// ══════════════════════════════════════════════════════════════════════
// Schemes catalog list — used by SchemesScreen
// ══════════════════════════════════════════════════════════════════════

class SchemesListState {
  const SchemesListState({
    this.schemes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.pagination,
  });

  final List<SchemeModel> schemes;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final SchemePagination? pagination;

  bool get hasMore => pagination?.hasMore ?? false;
  bool get isEmpty => !isLoading && errorMessage == null && schemes.isEmpty;

  SchemesListState copyWith({
    List<SchemeModel>? schemes,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    SchemePagination? pagination,
  }) {
    return SchemesListState(
      schemes: schemes ?? this.schemes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      pagination: pagination ?? this.pagination,
    );
  }
}

class SchemesListNotifier extends Notifier<SchemesListState> {
  static const _pageLimit = 10;

  @override
  SchemesListState build() {
    Future.microtask(loadFirstPage);
    return const SchemesListState(isLoading: true);
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await ref.read(schemesRepositoryProvider).getSchemes(page: 1, limit: _pageLimit);
    result.when(
      success: (page) => state = state.copyWith(
        isLoading: false,
        schemes: page.schemes,
        pagination: page.pagination,
      ),
      failure: (e) => state = state.copyWith(isLoading: false, errorMessage: e.message),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final nextPage = (state.pagination?.page ?? 1) + 1;
    state = state.copyWith(isLoadingMore: true);
    final result = await ref
        .read(schemesRepositoryProvider)
        .getSchemes(page: nextPage, limit: state.pagination?.limit ?? _pageLimit);
    result.when(
      success: (page) => state = state.copyWith(
        isLoadingMore: false,
        schemes: [...state.schemes, ...page.schemes],
        pagination: page.pagination,
      ),
      failure: (e) => state = state.copyWith(isLoadingMore: false, errorMessage: e.message),
    );
  }

  Future<void> refresh() => loadFirstPage();
}

final schemesListProvider = NotifierProvider<SchemesListNotifier, SchemesListState>(
  SchemesListNotifier.new,
);

// ══════════════════════════════════════════════════════════════════════
// Scheme detail + join — used by SchemeDetailScreen
// ══════════════════════════════════════════════════════════════════════

enum SchemeJoinStatus { idle, joining, success, kycRequired, error }

class SchemeDetailState {
  const SchemeDetailState({
    this.scheme,
    this.isLoading = false,
    this.errorMessage,
    this.joinStatus = SchemeJoinStatus.idle,
    this.joinErrorMessage,
    this.joinedScheme,
  });

  final SchemeModel? scheme;
  final bool isLoading;
  final String? errorMessage;
  final SchemeJoinStatus joinStatus;
  final String? joinErrorMessage;
  final UserSchemeModel? joinedScheme;

  bool get isJoining => joinStatus == SchemeJoinStatus.joining;

  SchemeDetailState copyWith({
    SchemeModel? scheme,
    bool? isLoading,
    String? errorMessage,
    SchemeJoinStatus? joinStatus,
    String? joinErrorMessage,
    UserSchemeModel? joinedScheme,
  }) {
    return SchemeDetailState(
      scheme: scheme ?? this.scheme,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      joinStatus: joinStatus ?? this.joinStatus,
      joinErrorMessage: joinErrorMessage,
      joinedScheme: joinedScheme ?? this.joinedScheme,
    );
  }
}

class SchemeDetailNotifier extends Notifier<SchemeDetailState> {
  @override
  SchemeDetailState build() => const SchemeDetailState();

  Future<void> loadDetail(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await ref.read(schemesRepositoryProvider).getSchemeDetail(id);
    result.when(
      success: (scheme) => state = state.copyWith(isLoading: false, scheme: scheme),
      failure: (e) => state = state.copyWith(isLoading: false, errorMessage: e.message),
    );
  }

  Future<void> join() async {
    final scheme = state.scheme;
    if (scheme == null || state.isJoining) return;

    state = state.copyWith(joinStatus: SchemeJoinStatus.joining, joinErrorMessage: null);
    final result = await ref.read(schemesRepositoryProvider).joinScheme(scheme.id);

    result.when(
      success: (userScheme) => state = state.copyWith(
        joinStatus: SchemeJoinStatus.success,
        joinedScheme: userScheme,
      ),
      failure: (e) {
        // NOTE: ApiException currently only carries `message`, not the
        // server's `errorCode`. KYC_REQUIRED (403) is detected here by
        // checking the message text — if the backend copy changes this
        // breaks silently. Consider adding `errorCode` to ApiException /
        // ForbiddenApiException in api_exceptions.dart for a robust check.
        final isKycRequired = e is ForbiddenApiException && e.message.toUpperCase().contains('KYC');
        state = state.copyWith(
          joinStatus: isKycRequired ? SchemeJoinStatus.kycRequired : SchemeJoinStatus.error,
          joinErrorMessage: e.message,
        );
      },
    );
  }

  void resetJoinStatus() {
    state = state.copyWith(joinStatus: SchemeJoinStatus.idle, joinErrorMessage: null);
  }
}

final schemeDetailProvider = NotifierProvider.autoDispose<SchemeDetailNotifier, SchemeDetailState>(
  SchemeDetailNotifier.new,
);

// ══════════════════════════════════════════════════════════════════════
// My Schemes list — GET /schemes/my-schemes
// Ready for MySchemeListScreen once that file is shared for wiring.
// ══════════════════════════════════════════════════════════════════════

class MySchemesState {
  const MySchemesState({
    this.schemes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<MySchemeModel> schemes;
  final bool isLoading;
  final String? errorMessage;

  MySchemesState copyWith({
    List<MySchemeModel>? schemes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MySchemesState(
      schemes: schemes ?? this.schemes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class MySchemesNotifier extends Notifier<MySchemesState> {
  @override
  MySchemesState build() {
    Future.microtask(load);
    return const MySchemesState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await ref.read(schemesRepositoryProvider).getMySchemes();
    result.when(
      success: (list) => state = state.copyWith(isLoading: false, schemes: list),
      failure: (e) => state = state.copyWith(isLoading: false, errorMessage: e.message),
    );
  }

  Future<void> refresh() => load();
}

final mySchemesProvider = NotifierProvider<MySchemesNotifier, MySchemesState>(
  MySchemesNotifier.new,
);