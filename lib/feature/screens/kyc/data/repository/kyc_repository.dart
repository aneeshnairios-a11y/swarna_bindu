import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarna_bindu/core/network/api_client.dart';
import 'package:swarna_bindu/core/network/api_endpoints.dart';
import 'package:swarna_bindu/core/network/api_result.dart';

import '../models/kyc_models.dart';

class KycRepository {
  KycRepository(this._apiClient);

  final ApiClient _apiClient;

  String _isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<MultipartFile> _toMultipart(File file) => MultipartFile.fromFile(
    file.path,
    filename: file.uri.pathSegments.last,
  );

  Future<ApiResult<PersonalInfoStepResult>> putPersonal({
    required String fullName,
    required DateTime dob,
    required String gender,
    required String email,
    File? profilePicture,
  }) async {
    final fields = <String, dynamic>{
      'fullName': fullName,
      'dob': _isoDate(dob),
      'gender': gender,
      'email': email,
    };
    if (profilePicture != null) {
      fields['profilePicture'] = await _toMultipart(profilePicture);
    }
    return _apiClient.uploadPut(
      ApiEndpoints.kycPersonal,
      formData: FormData.fromMap(fields),
      parser: (json) => PersonalInfoStepResult.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<IdentityStepResult>> putIdentity({
    required String aadhaarNumber,
    required String panNumber,
    bool digiLockerConnected = false,
    File? aadhaarFront,
    File? aadhaarBack,
    File? panCardPhoto,
  }) async {
    final fields = <String, dynamic>{
      'aadhaarNumber': aadhaarNumber,
      'panNumber': panNumber,
      'digiLockerConnected': digiLockerConnected.toString(),
    };
    if (aadhaarFront != null) fields['aadhaarFront'] = await _toMultipart(aadhaarFront);
    if (aadhaarBack != null) fields['aadhaarBack'] = await _toMultipart(aadhaarBack);
    if (panCardPhoto != null) fields['panCardPhoto'] = await _toMultipart(panCardPhoto);

    return _apiClient.uploadPut(
      ApiEndpoints.kycIdentity,
      formData: FormData.fromMap(fields),
      parser: (json) => IdentityStepResult.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<AddressStepResult>> putAddress({
    required String houseName,
    required String street,
    String? landmark,
    required String city,
    required String district,
    required String state,
    required String pinCode,
    double? latitude,
    double? longitude,
  }) {
    return _apiClient.put(
      ApiEndpoints.kycAddress,
      data: {
        'houseName': houseName,
        'street': street,
        if (landmark != null && landmark.trim().isNotEmpty) 'landmark': landmark,
        'city': city,
        'district': district,
        'state': state,
        'pinCode': pinCode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
      parser: (json) => AddressStepResult.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<BankStepResult>> putBank({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String confirmAccountNumber,
    required String ifscCode,
    required String branchName,
    String? upiId,
  }) {
    return _apiClient.put(
      ApiEndpoints.kycBank,
      data: {
        'accountHolderName': accountHolderName,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'confirmAccountNumber': confirmAccountNumber,
        'ifscCode': ifscCode,
        'branchName': branchName,
        if (upiId != null && upiId.trim().isNotEmpty) 'upiId': upiId,
      },
      parser: (json) => BankStepResult.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<KycStatusResult>> getStatus() {
    return _apiClient.get(
      ApiEndpoints.kycStatus,
      parser: (json) => KycStatusResult.fromJson(json as Map<String, dynamic>?),
    );
  }

  // TODO(kyc-submit): implement once POST /user/kyc/submit is finalized.
}

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return KycRepository(ref.watch(apiClientProvider));
});
