import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/invoice.dart';

enum SubscriptionPlan { free, premium, pro }

class BillingState {
  final SubscriptionPlan plan;
  final int chatUsed;
  final int chatLimit;
  final int memoryUsed;
  final int memoryLimit;
  final double amountPaid;
  final String nextBillingDate;
  final String paymentMethod;
  final List<Invoice> invoices;

  bool get isPremium => plan == SubscriptionPlan.premium || plan == SubscriptionPlan.pro;
  bool get isPro => plan == SubscriptionPlan.pro;
  bool get isFree => plan == SubscriptionPlan.free;

  BillingState({
    required this.plan,
    required this.chatUsed,
    required this.chatLimit,
    required this.memoryUsed,
    required this.memoryLimit,
    required this.amountPaid,
    required this.nextBillingDate,
    required this.paymentMethod,
    required this.invoices,
  });

  BillingState copyWith({
    SubscriptionPlan? plan,
    int? chatUsed,
    int? chatLimit,
    int? memoryUsed,
    int? memoryLimit,
    double? amountPaid,
    String? nextBillingDate,
    String? paymentMethod,
    List<Invoice>? invoices,
  }) {
    return BillingState(
      plan: plan ?? this.plan,
      chatUsed: chatUsed ?? this.chatUsed,
      chatLimit: chatLimit ?? this.chatLimit,
      memoryUsed: memoryUsed ?? this.memoryUsed,
      memoryLimit: memoryLimit ?? this.memoryLimit,
      amountPaid: amountPaid ?? this.amountPaid,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      invoices: invoices ?? this.invoices,
    );
  }
}

class BillingNotifier extends StateNotifier<BillingState> {
  BillingNotifier()
      : super(
          BillingState(
            plan: SubscriptionPlan.free,
            chatUsed: 38,
            chatLimit: 50,
            memoryUsed: 18,
            memoryLimit: 20,
            amountPaid: 0.0,
            nextBillingDate: 'August 1, 2026',
            paymentMethod: 'Not added',
            invoices: [],
          ),
        );

  void changePlan(SubscriptionPlan newPlan, {String paymentMethod = 'Visa **** 1234'}) {
    if (newPlan == SubscriptionPlan.free) {
      cancelSubscription();
      return;
    }

    final now = DateTime.now();
    final renewalDate = now.add(const Duration(days: 30));
    final dateStr = _formatDate(renewalDate);
    final double planPrice = newPlan == SubscriptionPlan.pro ? 599.0 : 299.0;
    final double planTax = newPlan == SubscriptionPlan.pro ? 107.0 : 53.0;
    final double planTotal = planPrice + planTax;

    final newInvoice = Invoice(
      id: 'INV-${now.year}-${100 + state.invoices.length + 1}',
      date: now,
      planName: newPlan == SubscriptionPlan.pro ? 'Pro Monthly' : 'Premium Monthly',
      amount: planPrice,
      tax: planTax,
      total: planTotal,
      status: 'Paid',
      paymentMethod: paymentMethod,
    );

    state = state.copyWith(
      plan: newPlan,
      chatLimit: 10000, // Unlimited or high limit
      memoryLimit: 10000,
      amountPaid: planPrice,
      nextBillingDate: dateStr,
      paymentMethod: paymentMethod,
      invoices: [newInvoice, ...state.invoices],
    );
  }

  void updatePaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void cancelSubscription() {
    state = state.copyWith(
      plan: SubscriptionPlan.free,
      chatLimit: 50,
      memoryLimit: 20,
      amountPaid: 0.0,
      nextBillingDate: 'August 1, 2026',
      paymentMethod: 'Not added',
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  return BillingNotifier();
});
