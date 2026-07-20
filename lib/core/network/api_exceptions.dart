import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

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

    switch (statusCode) {
      case 400:
        return ValidationApiException(
          serverMessage ?? 'Invalid request. Please check your input.',
          fieldErrors: _extractFieldErrors(e.response?.data),
        );
      case 401:
        return UnauthorizedApiException(
          serverMessage ?? 'Session expired. Please log in again.',
        );
      case 403:
        return ForbiddenApiException(
          serverMessage ?? 'You do not have permission to do this.',
        );
      case 404:
        return NotFoundApiException(
          serverMessage ?? 'The requested resource was not found.',
        );
      case 409:
        return ConflictApiException(
          serverMessage ?? 'This action conflicts with existing data.',
        );
      case 422:
        return ValidationApiException(
          serverMessage ?? 'Some fields are invalid.',
          fieldErrors: _extractFieldErrors(e.response?.data),
        );
      case 429:
        return RateLimitApiException(
          serverMessage ?? 'Too many attempts. Please wait and try again.',
        );
    }

    if (statusCode != null && statusCode >= 500) {
      return ServerApiException(
        serverMessage ?? 'Something went wrong on our end. Please try again.',
      );
    }

    return UnknownApiException(
      serverMessage ?? 'Something went wrong. Please try again.',
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error']) as String?;
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
  const UnauthorizedApiException(super.message);
}

final class ForbiddenApiException extends ApiException {
  const ForbiddenApiException(super.message);
}

final class NotFoundApiException extends ApiException {
  const NotFoundApiException(super.message);
}

final class ConflictApiException extends ApiException {
  const ConflictApiException(super.message);
}

final class ValidationApiException extends ApiException {
  const ValidationApiException(super.message, {this.fieldErrors});

  /// Field-level messages, e.g. `{ "aadhaar": "Invalid Aadhaar number" }`,
  /// so forms can highlight the exact input instead of a generic banner.
  final Map<String, String>? fieldErrors;
}

final class RateLimitApiException extends ApiException {
  const RateLimitApiException(super.message);
}

final class ServerApiException extends ApiException {
  const ServerApiException(super.message);
}

final class UnknownApiException extends ApiException {
  const UnknownApiException(super.message);
}
