import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:swarna_bindu/core/network/api_client.dart';
import 'package:swarna_bindu/core/network/api_endpoints.dart';
import 'package:swarna_bindu/core/network/api_result.dart';

import '../models/profile_response_model.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  /// `GET /user/profile`
  Future<ApiResult<ProfileData>> getProfile() {
    return _api.get<ProfileData>(
      ApiEndpoints.userProfileMe,
      parser: (json) => ProfileData.fromJson(json as Map<String, dynamic>?),
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});