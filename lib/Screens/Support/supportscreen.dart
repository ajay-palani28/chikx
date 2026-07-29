import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/chat_pod.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() {
        if (mounted) {
          ref.read(chatProvider.notifier).getMessages(context);
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonUI().myText(
                text: "LIVE NOW",
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textBrown,
              ),
              Gap(0.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonUI().myText(
                        text: "Chat with Admin",
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                      CommonUI().myText(
                        text: "Usually responds in 5 minutes",
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  _buildCircleIcon(Icons.restaurant, AppColors.primary),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: _buildChatBody(chatState),
        ),

        // Message Input
        _buildInputArea(),
      ],
    );
  }

  Widget _buildChatBody(ChatState state) {
    if (state is ChatLoadingState) {
      return CommonUI().chatListShimmer();
    } else if (state is ChatSuccessState) {
      if (state.messages.isEmpty) {
        return _buildEmptyState();
      }

      // Automatically scroll to bottom on new messages
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];
          bool isMe = message.senderType == 'user';
          return _buildMessageBubble(message, isMe);
        },
      );
    } else if (state is ChatErrorState) {
      return Center(child: Text("Error: ${state.exception}"));
    }
    return const SizedBox();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 50, color: Colors.black12),
          Gap(2.h),
          CommonUI().myText(
            text: "No messages yet. Say hi to the owner!",
            fontSize: 14.sp,
            color: Colors.black38,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isMe) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 75.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: isMe ? AppColors.chatOutgoing : AppColors.chatIncoming,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                ),
              ),
              child: CommonUI().myText(
                text: message.message ?? "",
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isMe ? Colors.white : Colors.black87,
                maxLines: 0,
              ),
            ),
            Gap(0.5.h),
            CommonUI().myText(
              text: message.createdAt != null ? DateFormat('hh:mm a').format(message.createdAt!) : "",
              fontSize: 10.sp,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppColors.fieldFill,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Message with the admin...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.black38,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isNotEmpty) {
                  ref.read(chatProvider.notifier).sendMessage(_messageController.text.trim(), context);
                  _messageController.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.textBrown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 24, color: color == AppColors.primary ? AppColors.textBrown : Colors.black45),
    );
  }
}
