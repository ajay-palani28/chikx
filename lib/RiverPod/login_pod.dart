import 'package:chikx/Models/app_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Network/api_manager.dart';
import '../Utils/app_alerController.dart';

abstract class LoginEvent {} 

class RegisterPodEvent extends LoginEvent {
  var payload;

  RegisterPodEvent(this.payload);
}

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessSate extends LoginState {
  final LoginResponseModel response;
  LoginSuccessSate(this.response);
}

class LoginErrorState extends LoginState {
  final String exception;
  LoginErrorState(this.exception);
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(LoginInitial());

  Future<void> loginUser(LoginModel payload, BuildContext context) async {
    state = LoginLoadingState();

    await ApiMethods().loginUser(
      payload: payload.toJson(),
      successBlock: (data) {
        if (data is Map) {
          final loginResponse = LoginResponseModel.fromJson(Map<String, dynamic>.from(data));
          if (!loginResponse.status || loginResponse.data == null) {
            String msg = loginResponse.message.isNotEmpty
                ? loginResponse.message
                : "Login failed";
            state = LoginErrorState(msg);
            AppAlertController().showAlert(message: msg, inContext: context);
          } else {
            state = LoginSuccessSate(loginResponse);
          }
        } else {
          String msg = "Invalid response format";
          state = LoginErrorState(msg);
          AppAlertController().showAlert(message: msg, inContext: context);
        }
      },
      failureBlock: (exception, data) {
        String msg = exception.toString();
        state = LoginErrorState(msg);
        AppAlertController().showAlert(
          message: msg,
          inContext: context,
        );
      },
    );
  }

  Future<void> loginWithGoogle(BuildContext context, {String? serverClientId}) async {
    state = LoginLoadingState();

    try {
      const String webClientId =
          '726578256225-0eu9r6ukeejq19dvh3mu7kd5bipnp77b.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: serverClientId ?? webClientId,
      );

      // Sign out first to allow picking account if previously attempted
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        state = LoginInitial();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        try {
          final OAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          idToken = await userCredential.user?.getIdToken();
        } catch (e) {
          debugPrint("Firebase credential error: $e");
        }
      }

      final String finalIdToken = idToken ?? '';

      if (finalIdToken.isEmpty) {
        String msg = "Google Sign-In failed to obtain ID token. Please ensure SHA-1 fingerprint is added in Firebase Console.";
        state = LoginErrorState(msg);
        AppAlertController().showAlert(message: msg, inContext: context);
        return;
      }

      final payload = {
        "idToken": finalIdToken,
        "email": googleUser.email,
        "fullName": googleUser.displayName ?? '',
      };

      await ApiMethods().googleLogin(
        payload: payload,
        successBlock: (data) {
          if (data is Map) {
            final loginResponse =
                LoginResponseModel.fromJson(Map<String, dynamic>.from(data));
            if (!loginResponse.status || loginResponse.data == null) {
              String msg = loginResponse.message.isNotEmpty
                  ? loginResponse.message
                  : "Google sign-in failed";
              state = LoginErrorState(msg);
              AppAlertController().showAlert(message: msg, inContext: context);
            } else {
              state = LoginSuccessSate(loginResponse);
            }
          } else {
            String msg = "Invalid response format";
            state = LoginErrorState(msg);
            AppAlertController().showAlert(message: msg, inContext: context);
          }
        },
        failureBlock: (exception, data) {
          String msg = exception.toString();
          state = LoginErrorState(msg);
          AppAlertController().showAlert(message: msg, inContext: context);
        },
      );
    } catch (e) {
      debugPrint("Google Sign-In Exception: $e");
      String errorMsg = e.toString();
      if (errorMsg.contains('10:') || errorMsg.contains('DEVELOPER_ERROR') || errorMsg.contains('sign_in_failed')) {
        errorMsg = "Google Sign-In Setup Required:\nPlease add your Android SHA-1 certificate fingerprint in Firebase Console (Project Settings -> Android App) and re-download google-services.json.";
      }
      state = LoginErrorState(errorMsg);
      AppAlertController().showAlert(message: errorMsg, inContext: context);
    }
  }
}