import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  const ApiException(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutApiException();
      case DioExceptionType.connectionError:
        return const NoInternetApiException();
      case DioExceptionType.cancel:
        return const RequestCancelledException();
      case DioExceptionType.badCertificate:
        return const ServerApiException(
          'Could not verify server security. Please try again later.',
        );
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    final statusCode = e.response?.statusCode;
    final serverMessage = _extractMessage(e.response?.data);
    final serverErrorCode = _extractErrorCode(e.response?.data);

    switch (statusCode) {
      case 400:
        return ValidationApiException(
          serverMessage ?? 'Invalid request. Please check your input.',
          fieldErrors: _extractFieldErrors(e.response?.data),
          errorCode: serverErrorCode,
        );
      case 401:
        return UnauthorizedApiException(
          serverMessage ?? 'Session expired. Please log in again.',
          errorCode: serverErrorCode,
        );
      case 403:
        return ForbiddenApiException(
          serverMessage ?? 'You do not have permission to do this.',
          errorCode: serverErrorCode,
        );
      case 404:
        return NotFoundApiException(
          serverMessage ?? 'The requested resource was not found.',
          errorCode: serverErrorCode,
        );
      case 409:
        return ConflictApiException(
          serverMessage ?? 'This action conflicts with existing data.',
          errorCode: serverErrorCode,
        );
      case 422:
        return ValidationApiException(
          serverMessage ?? 'Some fields are invalid.',
          fieldErrors: _extractFieldErrors(e.response?.data),
          errorCode: serverErrorCode,
        );
      case 429:
        return RateLimitApiException(
          serverMessage ?? 'Too many attempts. Please wait and try again.',
          errorCode: serverErrorCode,
        );
    }

    if (statusCode != null && statusCode >= 500) {
      return ServerApiException(
        serverMessage ?? 'Something went wrong on our end. Please try again.',
        errorCode: serverErrorCode,
      );
    }

    return UnknownApiException(
      serverMessage ?? 'Something went wrong. Please try again.',
      errorCode: serverErrorCode,
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error']) as String?;
    }
    return null;
  }

  static String? _extractErrorCode(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['errorCode'] as String?;
    }
    return null;
  }

  static Map<String, String>? _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return (data['errors'] as Map).map(
            (k, v) => MapEntry(
          k.toString(),
          v is List ? v.first.toString() : v.toString(),
        ),
      );
    }
    return null;
  }
}

final class NoInternetApiException extends ApiException {
  const NoInternetApiException([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

final class TimeoutApiException extends ApiException {
  const TimeoutApiException([
    super.message = 'Request timed out. Please try again.',
  ]);
}

final class RequestCancelledException extends ApiException {
  const RequestCancelledException([super.message = 'Request was cancelled.']);
}

final class UnauthorizedApiException extends ApiException {
  const UnauthorizedApiException(super.message, {super.errorCode});
}

final class ForbiddenApiException extends ApiException {
  const ForbiddenApiException(super.message, {super.errorCode});
}

final class NotFoundApiException extends ApiException {
  const NotFoundApiException(super.message, {super.errorCode});
}

final class ConflictApiException extends ApiException {
  const ConflictApiException(super.message, {super.errorCode});
}

final class ValidationApiException extends ApiException {
  const ValidationApiException(super.message, {this.fieldErrors, super.errorCode});

  /// Field-level messages, e.g. `{ "aadhaar": "Invalid Aadhaar number" }`,
  /// so forms can highlight the exact input instead of a generic banner.
  final Map<String, String>? fieldErrors;
}

final class RateLimitApiException extends ApiException {
  const RateLimitApiException(super.message, {super.errorCode});
}

final class ServerApiException extends ApiException {
  const ServerApiException(super.message, {super.errorCode});
}

final class UnknownApiException extends ApiException {
  const UnknownApiException(super.message, {super.errorCode});
}