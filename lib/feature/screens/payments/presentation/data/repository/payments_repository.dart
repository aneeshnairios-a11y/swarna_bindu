import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:swarna_bindu/core/network/api_client.dart';
import 'package:swarna_bindu/core/network/api_endpoints.dart';
import 'package:swarna_bindu/core/network/api_result.dart';

import '../models/payment_dues_model.dart';
import '../models/payment_history_model.dart';
import '../models/payment_initialize_model.dart';
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
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(apiClientProvider));
});