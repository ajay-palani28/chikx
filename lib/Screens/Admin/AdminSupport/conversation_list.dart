import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/chat_pod.dart';
import 'package:chikx/Screens/Admin/AdminSupport/admin_support.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class AdminConversationListScreen extends ConsumerStatefulWidget {
  const AdminConversationListScreen({super.key});

  @override
  ConsumerState<AdminConversationListScreen> createState() => _AdminConversationListScreenState();
}

class _AdminConversationListScreenState extends ConsumerState<AdminConversationListScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() {
        if (mounted) {
          ref.read(adminConversationProvider.notifier).getAdminConversations(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(adminConversationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonUI().myText(
                  text: "Customer Support",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
                CommonUI().myText(
                  text: "Respond to customer inquiries",
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildConversationList(chatState),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(ChatState state) {
    if (state is ChatLoadingState) {
      return ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Row(
            children: [
              CommonUI().commonShimmerEffect(height: 50, width: 50, borderradius: 25),
              Gap(4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonUI().commonShimmerEffect(height: 2.h, width: 40.w),
                    Gap(0.5.h),
                    CommonUI().commonShimmerEffect(height: 1.5.h, width: 60.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (state is AdminConversationsSuccessState) {
      if (state.conversations.isEmpty) {
        return Center(child: Text("No conversations yet."));
      }
      return ListView.builder(
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          final conv = state.conversations[index];
          return _buildConversationTile(conv);
        },
      );
    } else if (state is ChatErrorState) {
      return Center(child: Text("Error: ${state.exception}"));
    }
    return const SizedBox();
  }

  Widget _buildConversationTile(ChatConversationModel conv) {
    return InkWell(
      onTap: () {
        if (conv.userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminSupport(userId: conv.userId!, userName: conv.fullName ?? "User"),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(Icons.person, color: AppColors.textBrown),
            ),
            Gap(4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonUI().myText(
                        text: conv.fullName ?? "Unknown User",
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                      if (conv.lastMessageAt != null)
                        CommonUI().myText(
                          text: DateFormat('hh:mm a').format(conv.lastMessageAt!),
                          fontSize: 10.sp,
                          color: Colors.black38,
                        ),
                    ],
                  ),
                  Gap(0.5.h),
                  CommonUI().myText(
                    text: conv.lastMessage ?? "No messages yet",
                    fontSize: 12.sp,
                    color: Colors.black54,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
