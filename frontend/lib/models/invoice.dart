class Invoice {
  final String id;
  final DateTime date;
  final String planName;
  final double amount;
  final double tax;
  final double total;
  final String status;
  final String paymentMethod;

  const Invoice({
    required this.id,
    required this.date,
    required this.planName,
    required this.amount,
    required this.tax,
    required this.total,
    required this.status,
    required this.paymentMethod,
  });

  Invoice copyWith({
    String? id,
    DateTime? date,
    String? planName,
    double? amount,
    double? tax,
    double? total,
    String? status,
    String? paymentMethod,
  }) {
    return Invoice(
      id: id ?? this.id,
      date: date ?? this.date,
      planName: planName ?? this.planName,
      amount: amount ?? this.amount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
