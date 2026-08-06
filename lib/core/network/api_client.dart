import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_exceptions.dart';
import 'api_result.dart';
import 'dio_client.dart';
import 'network_info.dart';

/// Thin, typed wrapper around Dio. Every Phase 2 repository should go
/// through this instead of touching Dio directly — it centralizes the
/// `{ success, message, data }` envelope unwrap (Section 6), error mapping,
/// and the offline pre-check, so ViewModels only ever see [ApiResult].
class ApiClient {
  ApiClient(this._dio, this._networkInfo);

  final Dio _dio;
  final NetworkInfo _networkInfo;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) => _request(
    () => _dio.get(path, queryParameters: queryParameters),
    parser,
  );

  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
  }) => _request(() => _dio.post(path, data: data), parser);

  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
  }) => _request(() => _dio.patch(path, data: data), parser);

  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
  }) => _request(() => _dio.put(path, data: data), parser);

  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
  }) => _request(() => _dio.delete(path, data: data), parser);

  /// Multipart upload — e.g. KYC Aadhaar/PAN images (pre-compressed to
  /// max 2MB per Section 12, compression happens in the repository layer).
  Future<ApiResult<T>> upload<T>(
    String path, {
    required FormData formData,
    required T Function(dynamic json) parser,
    void Function(int sent, int total)? onSendProgress,
  }) => _request(
    () => _dio.post(path, data: formData, onSendProgress: onSendProgress),
    parser,
  );

  /// Downloads a binary file (e.g. `GET /enrollments/:id/statement`) to
  /// [savePath] and returns that path on success.
  Future<ApiResult<String>> download(String path, String savePath) => _request(() async {
    await _dio.download(path, savePath);
    return Response(
      requestOptions: RequestOptions(path: path),
      data: savePath,
    );
  }, (json) => json as String);

  Future<ApiResult<T>> _request<T>(
    Future<Response> Function() call,
    T Function(dynamic json) parser,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const ApiFailure(NoInternetApiException());
    }

    try {
      final response = await call();
      final body = response.data;
      // Unwrap the standard { success, message, data } envelope when
      // present; fall back to the raw body for endpoints that don't use it
      // (e.g. the download() case above, which passes the saved path).
      final payload = (body is Map<String, dynamic> && body.containsKey('data')) ? body['data'] : body;
      return ApiSuccess(parser(payload));
    } on DioException catch (e) {
      return ApiFailure(ApiException.fromDioException(e));
    } catch (e) {
      return ApiFailure(UnknownApiException(e.toString()));
    }
  }

  Future<ApiResult<T>> uploadPut<T>(
    String path, {
    required FormData formData,
    required T Function(dynamic json) parser,
    void Function(int sent, int total)? onSendProgress,
  }) => _request(
    () => _dio.put(path, data: formData, onSendProgress: onSendProgress),
    parser,
  );
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider), ref.watch(networkInfoProvider));
});
