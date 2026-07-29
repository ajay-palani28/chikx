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


class AdminSupport extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  const AdminSupport({super.key, required this.userId, required this.userName});

  @override
  ConsumerState<AdminSupport> createState() => _AdminSupportState();
}

class _AdminSupportState extends ConsumerState<AdminSupport> {
  final TextEditingController _responseController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() {
        if (mounted) {
          ref.read(chatProvider.notifier).getAdminConversationByUser(widget.userId, context);
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

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.bgColor,
          title: CommonUI().myText(text: widget.userName, fontSize: 16.sp, fontWeight: FontWeight.w800),
          iconTheme: const IconThemeData(color: AppColors.textBrown),
        ),
        backgroundColor: AppColors.bgColor,
        body: Column(
          children: [
            Expanded(
              child: _buildChatBody(chatState),
            ),

            // Input Bar
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBody(ChatState state) {
    if (state is ChatLoadingState) {
      return CommonUI().chatListShimmer();
    } else if (state is ChatSuccessState) {
      if (state.messages.isEmpty) {
        return const Center(child: Text("No messages yet."));
      }

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(5.w),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];
          bool isMe = message.senderType == 'admin';
          return _buildMessageBubble(message, isMe);
        },
      );
    } else if (state is ChatErrorState) {
      return Center(child: Text("Error: ${state.exception}"));
    }
    return const SizedBox();
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
                color: isMe ? const Color(0xFF745223) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: isMe ? null : Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: CommonUI().myText(
                text: message.message ?? "",
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
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
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F4EF),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: TextField(
                controller: _responseController,
                decoration: InputDecoration(
                  hintText: "Type your response...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.black38,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Gap(3.w),
          GestureDetector(
            onTap: () {
              if (_responseController.text.trim().isNotEmpty) {
                ref.read(chatProvider.notifier).adminSendMessage(widget.userId, _responseController.text.trim(), context);
                _responseController.clear();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF745223),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
