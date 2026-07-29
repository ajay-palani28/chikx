import 'package:chikx/RiverPod/admin_deals_pod.dart';
import 'package:chikx/RiverPod/admin_users_pod.dart';
import 'package:chikx/RiverPod/chat_pod.dart';
import 'package:chikx/RiverPod/addFood_pod.dart';
import 'package:chikx/RiverPod/create_account_pod.dart';
import 'package:chikx/RiverPod/login_pod.dart';
import 'package:chikx/RiverPod/profile_pod.dart';
import 'package:chikx/RiverPod/favorite_pod.dart';
import 'package:chikx/RiverPod/cart_pod.dart';
import 'package:chikx/RiverPod/forgot_password_pod.dart';
import 'package:chikx/RiverPod/payment_pod.dart';
import 'package:chikx/Screens/Login/login.dart';
import 'package:flutter_riverpod/legacy.dart';

final createAccountProvider =
StateNotifierProvider<CreateAccountNotifier, CreateAccountState>(
      (ref) => CreateAccountNotifier(),
);

final loginProvider =
StateNotifierProvider<LoginNotifier, LoginState>(
      (ref) => LoginNotifier(),
);

final foodProvider =
StateNotifierProvider<FoodNotifier, FoodState>(
      (ref) => FoodNotifier(),
);

final getAdminFoodProvider =
StateNotifierProvider<FoodNotifier, FoodState>(
      (ref) => FoodNotifier(),
);

final getProfileProvider =
StateNotifierProvider<ProfileNotifier, ProfileState>(
      (ref) => ProfileNotifier(),
);

final favoriteProvider =
StateNotifierProvider<FavoriteNotifier, FavoriteState>(
      (ref) => FavoriteNotifier(),
);

final chatProvider =
StateNotifierProvider<ChatNotifier, ChatState>(
      (ref) => ChatNotifier(),
);

final adminConversationProvider =
StateNotifierProvider<ChatNotifier, ChatState>(
      (ref) => ChatNotifier(),
);

final cartProvider =
StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final forgotPasswordProvider =
StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
      (ref) => ForgotPasswordNotifier(),
);

final paymentProvider =
StateNotifierProvider<PaymentNotifier, PaymentState>(
      (ref) => PaymentNotifier(),
);

final adminUsersProvider =
StateNotifierProvider<AdminUsersNotifier, AdminUsersState>(
      (ref) => AdminUsersNotifier(),
);

final adminDealsProvider =
StateNotifierProvider<AdminDealsNotifier, AdminDealsState>(
      (ref) => AdminDealsNotifier(),
);
