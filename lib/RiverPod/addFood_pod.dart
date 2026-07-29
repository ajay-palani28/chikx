import 'package:chikx/Models/app_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../Network/api_manager.dart';
import '../Utils/app_alerController.dart';

abstract class FoodState {}

class FoodInitial extends FoodState {}

// Add Food States
class AddFoodLoadingState extends FoodState {}
class AddFoodSuccessSate extends FoodState {
  final dynamic data;
  AddFoodSuccessSate(this.data);
}
class AddFoodErrorState extends FoodState {
  final String exception;
  AddFoodErrorState(this.exception);
}

// Get Food States
class GetFoodLoadingState extends FoodState {}
class GetFoodSuccessSate extends FoodState {
  final List<GetFoodsModel> foods;
  GetFoodSuccessSate(this.foods);
}
class GetFoodErrorState extends FoodState {
  final String exception;
  GetFoodErrorState(this.exception);
}

class FoodNotifier extends StateNotifier<FoodState> {
  FoodNotifier() : super(FoodInitial());

  Future<void> addFoodEvent(var payload, BuildContext context) async {
    state = AddFoodLoadingState();
    await ApiMethods().addFoods(
      payload: payload,
      successBlock: (data) {
        state = AddFoodSuccessSate(data);
      },
      failureBlock: (exception, data) {
        state = AddFoodErrorState(exception.toString());
        AppAlertController().showAlert(
          message: exception.toString(),
          inContext: context,
        );
      },
    );
  }

  Future<void> updateFoodEvent(String foodId, var payload, BuildContext context) async {
    state = AddFoodLoadingState();
    await ApiMethods().updateFood(
      foodId: foodId,
      payload: payload,
      successBlock: (data) {
        state = AddFoodSuccessSate(data);
      },
      failureBlock: (exception, data) {
        state = AddFoodErrorState(exception.toString());
        AppAlertController().showAlert(
          message: exception.toString(),
          inContext: context,
        );
      },
    );
  }

  Future<void> deleteFoodEvent(String foodId, BuildContext context) async {
    state = AddFoodLoadingState();
    await ApiMethods().deleteFood(
      foodId: foodId,
      successBlock: (data) {
        state = AddFoodSuccessSate(data); // Using AddFoodSuccessSate to trigger refresh
      },
      failureBlock: (exception, data) {
        state = AddFoodErrorState(exception.toString());
        AppAlertController().showAlert(
          message: exception.toString(),
          inContext: context,
        );
      },
    );
  }

  Future<void> getFoods(String category, BuildContext context, {String? search}) async {
    state = GetFoodLoadingState();
    await ApiMethods().getFoods(
      food_category: category.isEmpty ? null : category,
      search: search?.isEmpty == true ? null : search,
      successBlock: (data) {
        List<GetFoodsModel> foodList = [];
        try {
          var list = data['data'];
          if (list is List) {
            foodList = list.map((e) => GetFoodsModel.fromJson(e)).toList();
          }
        } catch (e) {
          print("Error parsing foods: $e");
        }
        state = GetFoodSuccessSate(foodList);
      },
      failureBlock: (exception, data) {
        state = GetFoodErrorState(exception.toString());
      },
    );
  }
}
