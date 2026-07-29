import 'package:chikx/Utils/app_alerController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../Network/api_manager.dart';

abstract class CreateAccountEvent {

}

class RegisterPodEvent extends CreateAccountEvent{
  var payload;

  RegisterPodEvent(this.payload);
}

abstract class CreateAccountState{}

class CreateAccountInitial extends CreateAccountState{

}
class CreateAccountLoadingState extends CreateAccountState{

}
class CreateAccountSuccessSate extends CreateAccountState{
  var data;
  CreateAccountSuccessSate(this.data);
}
class CreateAccountErrorState extends CreateAccountState{
  String exception;
  CreateAccountErrorState(this.exception);
}

class CreateAccountNotifier
    extends StateNotifier<CreateAccountState> {

  CreateAccountNotifier()
      : super(CreateAccountInitial());

  Future<void> createAccount(
      var payload, BuildContext context) async {

    state = CreateAccountLoadingState();

    await ApiMethods().createAccount(

      payload: payload,

      successBlock: (data) {

        state = CreateAccountSuccessSate(data);

      },

      failureBlock: (exception, data) {

        state =
            CreateAccountErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);

      },
    );
  }
}