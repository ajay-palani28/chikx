import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Network/api_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

abstract class AdminUsersState {}

class AdminUsersInitialState extends AdminUsersState {}

class AdminUsersLoadingState extends AdminUsersState {}

class AdminUsersSuccessState extends AdminUsersState {
  final List<UserModel> users;
  AdminUsersSuccessState(this.users);
}

class AdminUsersErrorState extends AdminUsersState {
  final String message;
  AdminUsersErrorState(this.message);
}

class AdminUsersDeleteLoadingState extends AdminUsersState {
  final List<UserModel> users;
  AdminUsersDeleteLoadingState(this.users);
}

class AdminUsersDeleteSuccessState extends AdminUsersState {
  final List<UserModel> users;
  AdminUsersDeleteSuccessState(this.users);
}

class AdminUsersDeleteErrorState extends AdminUsersState {
  final List<UserModel> users;
  final String message;
  AdminUsersDeleteErrorState(this.users, this.message);
}

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  AdminUsersNotifier() : super(AdminUsersInitialState());

  List<UserModel> _allUsers = [];

  Future<void> fetchUsers() async {
    state = AdminUsersLoadingState();
    await ApiMethods().getAdminUsers(
      successBlock: (data) {
        if (data is List) {
          _allUsers = data.map((e) => UserModel.fromJson(e)).toList();
          state = AdminUsersSuccessState(_allUsers);
        } else if (data['data'] is List) {
          _allUsers = (data['data'] as List).map((e) => UserModel.fromJson(e)).toList();
          state = AdminUsersSuccessState(_allUsers);
        } else {
          state = AdminUsersErrorState("Invalid data format");
        }
      },
      failureBlock: (exception, data) {
        state = AdminUsersErrorState(exception.toString());
      },
    );
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      state = AdminUsersSuccessState(_allUsers);
    } else {
      final filteredUsers = _allUsers.where((user) {
        final name = user.fullName?.toLowerCase() ?? "";
        final email = user.email?.toLowerCase() ?? "";
        final phone = user.phone?.toLowerCase() ?? "";
        final search = query.toLowerCase();
        return name.contains(search) || email.contains(search) || phone.contains(search);
      }).toList();
      state = AdminUsersSuccessState(filteredUsers);
    }
  }

  Future<void> deleteUser(String userId, BuildContext context) async {
    final previousUsers = List<UserModel>.from(_allUsers);
    state = AdminUsersDeleteLoadingState(previousUsers);

    await ApiMethods().adminDeleteUser(
      userId: userId,
      successBlock: (data) {
        _allUsers.removeWhere((user) => user.id == userId);
        state = AdminUsersDeleteSuccessState(List.from(_allUsers));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted successfully")),
        );
        
        // Final state should be success with the updated list
        state = AdminUsersSuccessState(_allUsers);
      },
      failureBlock: (exception, data) {
        state = AdminUsersDeleteErrorState(previousUsers, exception.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete user: ${exception.toString()}")),
        );
        // Revert to success state with previous list after error
        state = AdminUsersSuccessState(previousUsers);
      },
    );
  }
}
