import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_event_bus.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';

Dio _buildBaseDio() {
  return Dio(
    BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: EnvConfig.connectTimeout,
      receiveTimeout: EnvConfig.receiveTimeout,
      sendTimeout: EnvConfig.sendTimeout,
      headers: const {'Accept': 'application/json'},
      contentType: 'application/json',
    ),
  );
}

/// Interceptor-free Dio used ONLY for token refresh + retry — see
/// [AuthInterceptor] doc comment for why this must stay separate from
/// [dioProvider].
final _refreshDioProvider = Provider<Dio>((ref) => _buildBaseDio());

/// The Dio instance every repository/ApiClient call should use.
final dioProvider = Provider<Dio>((ref) {
  final dio = _buildBaseDio();

  dio.interceptors.addAll([
    AuthInterceptor(
      refreshDio: ref.watch(_refreshDioProvider),
      secureStorage: ref.watch(secureStorageProvider),
      authEventBus: ref.watch(authEventBusProvider),
    ),
    if (kDebugMode) _debugLogInterceptor,
  ]);

  return dio;
});

final _debugLogInterceptor = LogInterceptor(
  requestHeader: false,
  responseHeader: false,
  requestBody: true,
  responseBody: true,
  error: true,
  logPrint: (obj) => debugPrint('[API] $obj'),
);
