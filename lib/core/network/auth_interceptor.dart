import 'dart:async';

import 'package:dio/dio.dart';

import '../services/auth_event_bus.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

/// Attaches the bearer token to every request and transparently refreshes
/// an expired access token on a 401, retrying the original request once.
///
/// Uses a single in-flight refresh via [_refreshCompleter] so that if N
/// requests hit 401 at the same time, only ONE refresh call is made and the
/// rest await its result — this is the "queue-based approach" required by
/// Section 12 of the project context, avoiding a refresh-storm race.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio refreshDio,
    required SecureStorageService secureStorage,
    required AuthEventBus authEventBus,
  }) : _refreshDio = refreshDio,
       _secureStorage = secureStorage,
       _authEventBus = authEventBus;

  /// A bare Dio instance with NO interceptors — used only for the refresh
  /// call and for retrying the original request, so a failed retry can
  /// never recursively trigger this same interceptor.
  final Dio _refreshDio;
  final SecureStorageService _secureStorage;
  final AuthEventBus _authEventBus;

  Completer<bool>? _refreshCompleter;

  bool _isPublicPath(String path) => ApiEndpoints.publicPaths.any((p) => path.contains(p));

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicPath(options.path)) {
      final token = await _secureStorage.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final requestPath = err.requestOptions.path;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (!isUnauthorized || _isPublicPath(requestPath) || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      await _secureStorage.clearAll();
      _authEventBus.notifySessionExpired();
      handler.next(err);
      return;
    }

    if (err.requestOptions.data is FormData) {
      handler.next(err);
      return;
    }

    try {
      final token = await _secureStorage.accessToken;
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $token'
        ..extra['retried'] = true;
      final response = await _refreshDio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Single-flight refresh: concurrent 401s share one refresh call instead
  /// of each firing its own (which would race and could invalidate a token
  /// another request just received).
  Future<bool> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _secureStorage.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final response = await _refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data is Map<String, dynamic> ? response.data['data'] as Map<String, dynamic>? : null;
      final newAccessToken = data?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _secureStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
      } else {
        await _secureStorage.updateAccessToken(newAccessToken);
      }

      _refreshCompleter!.complete(true);
      return true;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
