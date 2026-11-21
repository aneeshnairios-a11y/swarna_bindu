
class JuspayOrderStatusModel {
  const JuspayOrderStatusModel({
    required this.orderId,
    required this.status,
    required this.amount,
  });

  final String orderId;
  final String status;
  final num amount;

  bool get isCharged => status.toUpperCase() == 'CHARGED';

  factory JuspayOrderStatusModel.fromJson(Map<String, dynamic> json) {
    return JuspayOrderStatusModel(
      orderId: json['order_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: json['amount'] is num ? json['amount'] as num : 0,
    );
  }
}
