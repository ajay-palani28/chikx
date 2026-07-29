import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../Network/api_manager.dart';
import '../Utils/app_alerController.dart';

abstract class ProfileState{}

class ProfileInitial extends ProfileState{

}
class GetProfileLoadingState extends ProfileState{

}
class GetProfileSuccessSate extends ProfileState{
  var data;
  GetProfileSuccessSate(this.data);
}
class GetProfileErrorState extends ProfileState{
  String exception;
  GetProfileErrorState(this.exception);
}

class UploadProfileLoadingState extends ProfileState{

}
class UploadProfileSuccessSate extends ProfileState{
  var data;
  UploadProfileSuccessSate(this.data);
}
class UploadProfileErrorState extends ProfileState{
  String exception;
  UploadProfileErrorState(this.exception);
}

class ProfileNotifier
    extends StateNotifier<ProfileState> {

  ProfileNotifier()
      : super(ProfileInitial()); 

  Future<void> getProfile(
      var userId, BuildContext context) async {

    state = GetProfileLoadingState();

    await ApiMethods().profile(

      userId: userId,

      successBlock: (data) {

        state = GetProfileSuccessSate(data);

      },

      failureBlock: (exception, data) {
        state =
            GetProfileErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);

      },
    );
  }

  Future<void> uploadProfile(
      var userId, var payload, BuildContext context) async {

    state = UploadProfileLoadingState();

    await ApiMethods().profileUpload(

      userId: userId,
      payload: payload,

      successBlock: (data) {

        state = UploadProfileSuccessSate(data);
        // Automatically refresh profile data after successful upload
        getProfile(userId, context);

      },

      failureBlock: (exception, data) {
        state =
            UploadProfileErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);

      },
    );
  }
}