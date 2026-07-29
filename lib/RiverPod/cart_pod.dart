import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Network/api_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class CartItem {
  final GetFoodsModel food;
  int quantity;
  bool isSelected;

  CartItem({required this.food, this.quantity = 1, this.isSelected = true});
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  Future<void> getCart(String userId, BuildContext context) async {
    await ApiMethods().getFavorite(
      userId: userId,
      successBlock: (data) {
        try {
          var list = data['data']['favorites'];
          if (list is List) {
            state = list.map((e) {
              final model = FavoriteModel.fromJson(e);
              return CartItem(food: model.food ?? GetFoodsModel(id: ""));
            }).toList();
          }
        } catch (e) {
          print("Error parsing cart: $e");
        }
      },
      failureBlock: (exception, data) {},
    );
  }

  Future<void> addToCart(GetFoodsModel food, String userId, BuildContext context) async {
    var payload = {
      "userId": userId,
      "foodId": food.id,
    };
    await ApiMethods().addToFavorite(
      payload: payload,
      successBlock: (data) {
        getCart(userId, context);
      },
      failureBlock: (exception, data) {},
    );
  }

  Future<void> removeFromCart(String foodId, String userId, BuildContext context) async {
    await ApiMethods().deleteFavoriteFood(
      userId: userId,
      foodId: foodId,
      successBlock: (data) {
        getCart(userId, context);
      },
      failureBlock: (exception, data) {},
    );
  }

  void updateQuantity(String foodId, bool increase) {
    state = [
      for (final item in state)
        if (item.food.id == foodId)
          CartItem(
            food: item.food,
            quantity: increase ? item.quantity + 1 : (item.quantity > 1 ? item.quantity - 1 : 1),
            isSelected: item.isSelected,
          )
        else
          item
    ];
  }

  void clearCart() {
    state = [];
  }

  double get subtotal {
    return state.fold(0, (sum, item) => sum + ((item.food.price ?? 0) * item.quantity));
  }

  double get taxes {
    return subtotal * 0.18;
  }

  double get total {
    return subtotal + taxes;
  }
}
