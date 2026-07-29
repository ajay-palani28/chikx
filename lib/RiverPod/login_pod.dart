import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../Network/api_manager.dart';
import '../Utils/app_alerController.dart';

abstract class LoginEvent {

}

class RegisterPodEvent extends LoginEvent{
  var payload;

  RegisterPodEvent(this.payload);
}

abstract class LoginState{}

class LoginInitial extends LoginState{

}
class LoginLoadingState extends LoginState{

}
class LoginSuccessSate extends LoginState{
  var data;
  LoginSuccessSate(this.data);
}
class LoginErrorState extends LoginState{
  String exception;
  LoginErrorState(this.exception);
}

class LoginNotifier
    extends StateNotifier<LoginState> {

  LoginNotifier()
      : super(LoginInitial());

  Future<void> loginUser(
      var payload, BuildContext context) async {

    state = LoginLoadingState();

    await ApiMethods().loginUser(

      payload: payload,

      successBlock: (data) {

        state = LoginSuccessSate(data);

      },

      failureBlock: (exception, data) {

        state =
            LoginErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);

      },
    );
  }
}