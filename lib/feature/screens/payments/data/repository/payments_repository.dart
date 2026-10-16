import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:swarna_bindu/core/network/api_client.dart';
import 'package:swarna_bindu/core/network/api_endpoints.dart';
import 'package:swarna_bindu/core/network/api_exceptions.dart';
import 'package:swarna_bindu/core/network/api_result.dart';

import '../models/payment_dues_model.dart';
import '../models/payment_history_model.dart';
import '../models/payment_initialize_model.dart';
import '../models/payment_receipt_model.dart';
import '../models/payment_verify_model.dart';

/// One method per payments endpoint — mirrors the pattern established by
/// SchemesRepository / KycRepository (Section 6A). Every call returns
/// ApiResult<T>, so ViewModels never touch Dio/DioException directly.
class PaymentsRepository {
  PaymentsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<PaymentDuesModel>> getDues() {
    return _apiClient.get<PaymentDuesModel>(
      ApiEndpoints.paymentDues,
      parser: (json) => PaymentDuesModel.fromJson(json as Map<String, dynamic>?),
    );
  }

  Future<ApiResult<PaymentHistoryPageModel>> getHistory({
    required int page,
    required int limit,
  }) {
    return _apiClient.get<PaymentHistoryPageModel>(
      ApiEndpoints.paymentHistory,
      queryParameters: {'page': page, 'limit': limit},
      parser: (json) => PaymentHistoryPageModel.fromJson(json as Map<String, dynamic>?),
    );
  }

  Future<ApiResult<PaymentInitializeModel>> initializePayment({
    required String userSchemeId,
    required String installmentType,
    required num amount,
  }) {
    return _apiClient.post<PaymentInitializeModel>(
      ApiEndpoints.paymentInitialize,
      data: {
        'userSchemeId': userSchemeId,
        'installmentType': installmentType,
        'amount': amount,
      },
      parser: (json) => PaymentInitializeModel.fromJson(json as Map<String, dynamic>?),
    );
  }

  Future<ApiResult<PaymentVerifyModel>> verifyPayment({
    required String transactionId,
    required String status,
    required String paymentMethod,
  }) {
    return _apiClient.post<PaymentVerifyModel>(
      ApiEndpoints.paymentVerify,
      data: {
        'transactionId': transactionId,
        'status': status,
        'paymentMethod': paymentMethod,
      },
      parser: (json) => PaymentVerifyModel.fromJson(json as Map<String, dynamic>?),
    );
  }

  /// `GET /payments/receipt/:transactionId`
  Future<ApiResult<PaymentReceiptModel>> getReceipt(String transactionId) {
    return _apiClient.get<PaymentReceiptModel>(
      ApiEndpoints.paymentReceipt(transactionId),
      parser: (json) => PaymentReceiptModel.fromJson(json as Map<String, dynamic>?),
    );
  }

  /// `GET /payments/receipt/:transactionId/download` (PDF).
  ///
  /// Streams the PDF into the app's temp directory as
  /// `Receipt_<transactionId>.pdf` and returns that path. Moving it into the
  /// user's Downloads folder / sharing it is [ReceiptFileService]'s job.
  Future<ApiResult<String>> downloadReceipt(String transactionId) async {
    final String savePath;
    try {
      final dir = await getTemporaryDirectory();
      savePath = '${dir.path}/Receipt_$transactionId.pdf';
    } catch (e) {
      return ApiFailure(UnknownApiException(e.toString()));
    }

    final result = await _apiClient.download(
      ApiEndpoints.paymentReceiptDownload(transactionId),
      savePath,
    );

    // Guard against a non-PDF body being saved as ".pdf" (e.g. an HTML/JSON
    // error page that still came back with 200).
    final path = result.when(success: (p) => p, failure: (_) => null);
    if (path != null && !await _looksLikePdf(path)) {
      try {
        await File(path).delete();
      } catch (_) {}
      return const ApiFailure(UnknownApiException('The receipt file is invalid. Please try again.'));
    }
    return result;
  }

  Future<bool> _looksLikePdf(String path) async {
    try {
      final raf = await File(path).open();
      try {
        final head = await raf.read(4);
        // "%PDF"
        return head.length == 4 &&
            head[0] == 0x25 &&
            head[1] == 0x50 &&
            head[2] == 0x44 &&
            head[3] == 0x46;
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(apiClientProvider));
});