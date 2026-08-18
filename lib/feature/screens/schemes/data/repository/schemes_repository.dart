import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarna_bindu/core/network/api_client.dart';
import 'package:swarna_bindu/core/network/api_endpoints.dart';
import 'package:swarna_bindu/core/network/api_result.dart';

import '../../schemes_viewmodel/scheme_model.dart';
import '../models/scheme_response_model.dart';


/// Result shape for a paginated schemes page — kept as a small named record
/// rather than a class since it's only ever consumed inside this feature.
typedef SchemesPage = ({List<SchemeModel> schemes, SchemePagination pagination});

class SchemesRepository {
  SchemesRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<SchemesPage>> getSchemes({int page = 1, int limit = 10}) {
    return _api.get<SchemesPage>(
      ApiEndpoints.schemes,
      queryParameters: {'page': page, 'limit': limit},
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final schemes = (map['schemes'] as List<dynamic>? ?? [])
            .map((e) => SchemeModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final pagination = SchemePagination.fromJson(
          map['pagination'] as Map<String, dynamic>? ?? const {},
        );
        return (schemes: schemes, pagination: pagination);
      },
    );
  }

  Future<ApiResult<SchemeModel>> getSchemeDetail(String id) {
    return _api.get<SchemeModel>(
      ApiEndpoints.schemeDetail(id),
      parser: (json) => SchemeModel.fromJson(
        (json as Map<String, dynamic>)['scheme'] as Map<String, dynamic>,
      ),
    );
  }

  Future<ApiResult<UserSchemeModel>> joinScheme(String id) {
    return _api.post<UserSchemeModel>(
      ApiEndpoints.schemeJoin(id),
      parser: (json) => UserSchemeModel.fromJson(
        (json as Map<String, dynamic>)['userScheme'] as Map<String, dynamic>,
      ),
    );
  }

  Future<ApiResult<List<MySchemeModel>>> getMySchemes() {
    return _api.get<List<MySchemeModel>>(
      ApiEndpoints.mySchemes,
      parser: (json) => ((json as Map<String, dynamic>)['schemes'] as List<dynamic>? ?? [])
          .map((e) => MySchemeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

final schemesRepositoryProvider = Provider<SchemesRepository>((ref) {
  return SchemesRepository(ref.watch(apiClientProvider));
});