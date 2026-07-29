import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../Network/api_manager.dart';
import '../Utils/app_alerController.dart';

abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoadingState extends ForgotPasswordState {}

class ForgotPasswordQuestionsFetchedState extends ForgotPasswordState {
  final String question1;
  final String question2;
  ForgotPasswordQuestionsFetchedState(this.question1, this.question2);
}

class ForgotPasswordSuccessState extends ForgotPasswordState {
  final String message;
  ForgotPasswordSuccessState(this.message);
}

class ForgotPasswordErrorState extends ForgotPasswordState {
  final String exception;
  ForgotPasswordErrorState(this.exception);
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier() : super(ForgotPasswordInitial());

  Future<void> fetchSecurityQuestions(String email, BuildContext context) async {
    state = ForgotPasswordLoadingState();

    final payload = {"email": email};

    await ApiMethods().forgotPassword(
      payload: payload,
      successBlock: (data) {
        if (data['status'] == true) {
          state = ForgotPasswordQuestionsFetchedState(
            data['question1'] ?? "",
            data['question2'] ?? "",
          );
        } else {
          state = ForgotPasswordErrorState(data['message'] ?? "Failed to fetch questions");
          AppAlertController().showAlert(message: data['message'] ?? "Failed to fetch questions", inContext: context);
        }
      },
      failureBlock: (exception, data) {
        state = ForgotPasswordErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);
      },
    );
  }

  Future<void> verifyAnswersAndReset({
    required String email,
    required String answer1,
    required String answer2,
    required String password,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    state = ForgotPasswordLoadingState();

    final payload = {
      "email": email,
      "answer1": answer1,
      "answer2": answer2,
      "password": password,
      "confirmPassword": confirmPassword,
    };

    await ApiMethods().verifySecurityAnswers(
      payload: payload,
      successBlock: (data) {
        state = ForgotPasswordSuccessState(data['message'] ?? "Password updated successfully");
      },
      failureBlock: (exception, data) {
        state = ForgotPasswordErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);
      },
    );
  }
}
