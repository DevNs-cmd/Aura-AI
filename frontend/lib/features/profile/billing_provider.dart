import 'package:flutter_riverpod/flutter_riverpod.dart';

class BillingState {
  final bool isPremium;
  final int chatUsed;
  final int chatLimit;
  final int memoryUsed;
  final int memoryLimit;
  final double amountPaid;
  final String nextBillingDate;

  BillingState({
    required this.isPremium,
    required this.chatUsed,
    required this.chatLimit,
    required this.memoryUsed,
    required this.memoryLimit,
    required this.amountPaid,
    required this.nextBillingDate,
  });

  BillingState copyWith({
    bool? isPremium,
    int? chatUsed,
    int? chatLimit,
    int? memoryUsed,
    int? memoryLimit,
    double? amountPaid,
    String? nextBillingDate,
  }) {
    return BillingState(
      isPremium: isPremium ?? this.isPremium,
      chatUsed: chatUsed ?? this.chatUsed,
      chatLimit: chatLimit ?? this.chatLimit,
      memoryUsed: memoryUsed ?? this.memoryUsed,
      memoryLimit: memoryLimit ?? this.memoryLimit,
      amountPaid: amountPaid ?? this.amountPaid,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
    );
  }
}

class BillingNotifier extends StateNotifier<BillingState> {
  BillingNotifier()
    : super(
        BillingState(
          isPremium: false, // Starts as Free plan user
          chatUsed: 38,
          chatLimit: 50,
          memoryUsed: 18,
          memoryLimit: 20,
          amountPaid: 0.0,
          nextBillingDate: 'August 1, 2026',
        ),
      );

  void upgradeToPremium() {
    state = state.copyWith(
      isPremium: true,
      chatLimit: 10000, // Unlimited or high limit
      memoryLimit: 10000,
      amountPaid: 9.99,
      nextBillingDate: 'August 11, 2026',
    );
  }

  void cancelSubscription() {
    state = state.copyWith(
      isPremium: false,
      chatLimit: 50,
      memoryLimit: 20,
      amountPaid: 0.0,
      nextBillingDate: 'August 1, 2026',
    );
  }
}

final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((
  ref,
) {
  return BillingNotifier();
});
