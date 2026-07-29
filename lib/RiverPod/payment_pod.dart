import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Network/api_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoadingState extends PaymentState {}

class PaymentSuccessState extends PaymentState {
  final PaymentHistoryModel history;
  PaymentSuccessState(this.history);
}

class PaymentErrorState extends PaymentState {
  final String exception;
  PaymentErrorState(this.exception);
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(PaymentInitial());

  Future<void> getPaymentHistory(BuildContext context) async {
    state = PaymentLoadingState();
    await ApiMethods().getPaymentHistory(
      successBlock: (data) {
        try {
          final history = PaymentHistoryModel.fromJson(data['data']);
          state = PaymentSuccessState(history);
        } catch (e) {
          print("Error parsing payment history: $e");
          state = PaymentErrorState(e.toString());
        }
      },
      failureBlock: (exception, data) {
        state = PaymentErrorState(exception.toString());
      },
    );
  }
}
