import 'package:flutter_test/flutter_test.dart';
import 'package:swarna_bindu/feature/screens/payments/data/models/juspay_order_status_model.dart';

void main() {
  test('parses the order ID and charged status from Juspay response', () {
    final order = JuspayOrderStatusModel.fromJson({
      'order_id': 'ordmwdxtoj877ez',
      'status': 'CHARGED',
      'amount': 1,
    });

    expect(order.orderId, 'ordmwdxtoj877ez');
    expect(order.isCharged, isTrue);
  });

  test('non-charged status is not treated as a successful payment', () {
    final order = JuspayOrderStatusModel.fromJson({
      'order_id': 'ordmwdxtoj877ez',
      'status': 'PENDING',
      'amount': 1,
    });

    expect(order.isCharged, isFalse);
  });
}
