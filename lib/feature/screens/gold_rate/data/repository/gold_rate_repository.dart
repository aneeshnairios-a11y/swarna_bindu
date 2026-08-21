import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_result.dart';
import '../models/gold_rate_model.dart';

/// Mirrors the KYC/Schemes repository convention — one method per endpoint,
/// returns [ApiResult]<T>, no business logic beyond the network call itself.
class GoldRateRepository {
  GoldRateRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<GoldRateModel>> getTodayRate() {
    return _apiClient.get<GoldRateModel>(
      ApiEndpoints.goldRateToday,
      parser: (json) => GoldRateModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

final goldRateRepositoryProvider = Provider<GoldRateRepository>((ref) {
  return GoldRateRepository(ref.watch(apiClientProvider));
});