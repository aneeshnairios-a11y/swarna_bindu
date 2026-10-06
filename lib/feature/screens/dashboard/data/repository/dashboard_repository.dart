import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:swarna_bindu/core/network/api_client.dart';
import 'package:swarna_bindu/core/network/api_endpoints.dart';
import 'package:swarna_bindu/core/network/api_result.dart';

import '../models/dashboard_response_model.dart';

/// One method per endpoint, always returns [ApiResult] (never throws).
class DashboardRepository {
  DashboardRepository(this._api);

  final ApiClient _api;

  /// GET /user/dashboard
  Future<ApiResult<DashboardData>> getDashboard() => _api.get<DashboardData>(
    ApiEndpoints.userDashboard,
    parser: (json) => DashboardData.fromJson(json as Map<String, dynamic>),
  );
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider));
});