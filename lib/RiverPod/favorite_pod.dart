import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Network/api_manager.dart';
import 'package:chikx/Utils/app_alerController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class GetFavoriteLoadingState extends FavoriteState {}

class GetFavoriteSuccessState extends FavoriteState {
  final List<FavoriteModel> favorites;
  GetFavoriteSuccessState(this.favorites);
}

class GetFavoriteErrorState extends FavoriteState {
  final String exception;
  GetFavoriteErrorState(this.exception);
}

class FavoriteActionLoadingState extends FavoriteState {}

class FavoriteActionSuccessState extends FavoriteState {
  final String message;
  FavoriteActionSuccessState(this.message);
}

class FavoriteActionErrorState extends FavoriteState {
  final String exception;
  FavoriteActionErrorState(this.exception);
}

class FavoriteNotifier extends StateNotifier<FavoriteState> {
  FavoriteNotifier() : super(FavoriteInitial());

  Future<void> getFavorites(String userId, BuildContext context) async {
    state = GetFavoriteLoadingState();
    await ApiMethods().getFavorite(
      userId: userId,
      successBlock: (data) {
        List<FavoriteModel> favorites = [];
        try {
          var list = data['data']['favorites'];
          if (list is List) {
            favorites = list.map((e) => FavoriteModel.fromJson(e)).toList();
          }
        } catch (e) {
          print("Error parsing favorites: $e");
        }
        state = GetFavoriteSuccessState(favorites);
      },
      failureBlock: (exception, data) {
        state = GetFavoriteErrorState(exception.toString());
      },
    );
  }

  Future<void> addToFavorite(String userId, String foodId, BuildContext context) async {
    state = FavoriteActionLoadingState();
    var payload = {
      "userId": userId,
      "foodId": foodId,
    };
    await ApiMethods().addToFavorite(
      payload: payload,
      successBlock: (data) {
        state = FavoriteActionSuccessState(data['message'] ?? "Added to favorites");
        getFavorites(userId, context); // Refresh list
      },
      failureBlock: (exception, data) {
        state = FavoriteActionErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);
      },
    );
  }

  Future<void> removeFavorite(String userId, String foodId, BuildContext context) async {
    state = FavoriteActionLoadingState();
    await ApiMethods().deleteFavoriteFood(
      userId: userId,
      foodId: foodId,
      successBlock: (data) {
        state = FavoriteActionSuccessState(data['message'] ?? "Removed from favorites");
        getFavorites(userId, context); // Refresh list
      },
      failureBlock: (exception, data) {
        state = FavoriteActionErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);
      },
    );
  }
}
