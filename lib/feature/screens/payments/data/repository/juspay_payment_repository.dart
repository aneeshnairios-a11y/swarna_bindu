
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/juspay_order_status_model.dart';

class JuspayPaymentRepository {
  JuspayPaymentRepository(this._dio);

  final Dio _dio;

  static const String _baseUrl =
      'https://paymentgateway.bindujewellery.com';

  Future<JuspayOrderStatusModel> getOrderStatus(String orderId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/orderStatus/${Uri.encodeComponent(orderId)}',
    );

    final data = response.data;

    if (data == null) {
      throw const FormatException('Empty payment status response.');
    }

    return JuspayOrderStatusModel.fromJson(data);
  }
}

final juspayPaymentRepositoryProvider =
    Provider<JuspayPaymentRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  ref.onDispose(dio.close);

  return JuspayPaymentRepository(dio);
});
