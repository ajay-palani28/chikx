import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Network/api_manager.dart';
import 'package:chikx/Utils/app_alerController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatSuccessState extends ChatState {
  final List<ChatMessageModel> messages;
  ChatSuccessState(this.messages);
}

class ChatErrorState extends ChatState {
  final String exception;
  ChatErrorState(this.exception);
}

class AdminConversationsSuccessState extends ChatState {
  final List<ChatConversationModel> conversations;
  AdminConversationsSuccessState(this.conversations);
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatInitial());

  // User: Get conversation with Admin
  Future<void> getMessages(BuildContext context) async {
    state = ChatLoadingState();
    await ApiMethods().getMessages(
      successBlock: (data) {
        List<ChatMessageModel> messages = [];
        try {
          // User API returns messages in 'data'
          var list = data['data'];
          if (list is List) {
            messages = list.map((e) => ChatMessageModel.fromJson(e)).toList();
          }
        } catch (e) {
          print("Error parsing messages: $e");
        }
        state = ChatSuccessState(messages);
      },
      failureBlock: (exception, data) {
        state = ChatErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);
      },
    );
  }

  // User: Send message to Admin
  Future<void> sendMessage(String message, BuildContext context) async {
    var payload = {"message": message};
    await ApiMethods().sendMessage(
      payload: payload,
      successBlock: (data) {
        getMessages(context);
      },
      failureBlock: (exception, data) {
        AppAlertController().showAlert(message: exception.toString(), inContext: context);
      },
    );
  }

  // Admin: Get all conversations
  Future<void> getAdminConversations(BuildContext context) async {
    state = ChatLoadingState();
    await ApiMethods().getAdminConversations(
      successBlock: (data) {
        List<ChatConversationModel> conversations = [];
        try {
          // Admin List API returns conversations in 'data'
          var list = data['data'];
          if (list is List) {
            conversations = list.map((e) => ChatConversationModel.fromJson(e)).toList();
          }
        } catch (e) {
          print("Error parsing conversations: $e");
        }
        state = AdminConversationsSuccessState(conversations);
      },
      failureBlock: (exception, data) {
        state = ChatErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);
      },
    );
  }

  // Admin: Get specific user conversation
  Future<void> getAdminConversationByUser(String userId, BuildContext context) async {
    state = ChatLoadingState();
    await ApiMethods().getAdminConversationByUser(
      userId: userId,
      successBlock: (data) {
        List<ChatMessageModel> messages = [];
        try {
          // The admin API returns { "user": ..., "messages": [...] } inside 'data'
          if (data != null && data['data'] != null) {
            var innerData = data['data'];
            var list = innerData['messages'];
            if (list is List) {
              messages = list.map((e) => ChatMessageModel.fromJson(e)).toList();
              print("Successfully parsed ${messages.length} messages for admin");
            } else {
              print("Messages field is not a list or missing");
            }
          } else {
            print("Response data is null or empty");
          }
        } catch (e) {
          print("Error parsing admin messages: $e");
        }
        state = ChatSuccessState(messages);
      },
      failureBlock: (exception, data) {
        state = ChatErrorState(exception.toString());
        AppAlertController().showAlert(message: exception.toString(), inContext: context);
      },
    );
  }

  // Admin: Send message to specific user
  Future<void> adminSendMessage(String userId, String message, BuildContext context) async {
    var payload = {
      "userId": userId,
      "message": message,
    };
    await ApiMethods().adminSendMessage(
      payload: payload,
      successBlock: (data) {
        getAdminConversationByUser(userId, context);
      },
      failureBlock: (exception, data) {
        AppAlertController().showAlert(message: exception.toString(), inContext: context);
      },
    );
  }
}
