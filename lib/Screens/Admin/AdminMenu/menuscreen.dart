import 'dart:convert';
import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/admin_users_pod.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

class AdminMenuScreen extends ConsumerStatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  ConsumerState<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends ConsumerState<AdminMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      Future.microtask(() => ref.read(adminUsersProvider.notifier).fetchUsers());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonUI().myText(
              text: "Users Management",
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
            CommonUI().myText(
              text: "Manage your registered users here.",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            Gap(2.h),
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => ref.read(adminUsersProvider.notifier).searchUsers(value),
                decoration: InputDecoration(
                  hintText: "Search by name, email or phone...",
                  hintStyle: TextStyle(fontSize: 12.sp, color: Colors.black38),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textBrown),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.black38),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(adminUsersProvider.notifier).searchUsers("");
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                ),
              ),
            ),
            Gap(3.h),

            // Users List
            Expanded(
              child: _buildUsersList(usersState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(AdminUsersState state) {
    if (state is AdminUsersLoadingState) {
      return SingleChildScrollView(
        child: CommonUI().userListShimmer(),
      );
    } else if (state is AdminUsersErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            Gap(2.h),
            CommonUI().myText(text: state.message, fontSize: 13.sp, color: Colors.black54),
            Gap(2.h),
            ElevatedButton(
              onPressed: () => ref.read(adminUsersProvider.notifier).fetchUsers(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Retry", style: TextStyle(color: AppColors.textBrown)),
            )
          ],
        ),
      );
    }
    
    List<UserModel> users = [];
    if (state is AdminUsersSuccessState) {
      users = state.users;
    } else if (state is AdminUsersDeleteLoadingState) {
      users = state.users;
    } else if (state is AdminUsersDeleteSuccessState) {
      users = state.users;
    } else if (state is AdminUsersDeleteErrorState) {
      users = state.users;
    }

    if (users.isEmpty && state is! AdminUsersDeleteLoadingState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 60, color: Colors.black12),
            Gap(2.h),
            CommonUI().myText(
              text: "No users found",
              fontSize: 14.sp,
              color: Colors.black38,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => ref.read(adminUsersProvider.notifier).fetchUsers(),
          color: AppColors.primary,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(user);
            },
          ),
        ),
        if (state is AdminUsersDeleteLoadingState)
          Container(
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProfileImage(user),
          Gap(4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonUI().myText(
                  text: user.fullName ?? "No Name",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
                Gap(0.5.h),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: Colors.black45),
                    Gap(2.w),
                    Expanded(
                      child: CommonUI().myText(
                        text: user.email ?? "No Email",
                        fontSize: 11.sp,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Gap(0.5.h),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: Colors.black45),
                    Gap(2.w),
                    CommonUI().myText(
                      text: user.phone ?? "No Phone",
                      fontSize: 11.sp,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showDeleteDialog(user),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserModel user) {
    String? profileImage = user.profileImage;

    return GestureDetector(
      onTap: () {
        if (profileImage != null && profileImage.isNotEmpty) {
          _showImagePreview(user);
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.2),
          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
        ),
        child: ClipOval(
          child: profileImage != null && profileImage.isNotEmpty
              ? _buildBase64Image(profileImage)
              : Center(
                  child: user.fullName != null && user.fullName!.isNotEmpty
                      ? Text(
                          user.fullName![0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textBrown,
                          ),
                        )
                      : const Icon(Icons.person, color: AppColors.textBrown, size: 30),
                ),
        ),
      ),
    );
  }

  void _showImagePreview(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: AppColors.textBrown, size: 20),
                ),
              ),
            ),
            Container(
              width: 90.w,
              constraints: BoxConstraints(maxHeight: 60.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: _buildBase64Image(user.profileImage!, isDetailed: true),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonUI().myText(
                            text: user.fullName ?? "User Profile",
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                          CommonUI().myText(
                            text: user.email ?? "",
                            fontSize: 12.sp,
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBase64Image(String imageData, {bool isDetailed = false}) {
    try {
      String base64Str = imageData;
      if (imageData.contains(',')) {
        base64Str = imageData.split(',').last;
      }
      return Image.memory(
        base64Decode(base64Str),
        fit: isDetailed ? BoxFit.contain : BoxFit.cover,
        width: isDetailed ? double.infinity : 60,
        height: isDetailed ? null : 60,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.person,
          color: AppColors.textBrown,
          size: isDetailed ? 100 : 30,
        ),
      );
    } catch (e) {
      return Icon(
        Icons.person,
        color: AppColors.textBrown,
        size: isDetailed ? 100 : 30,
      );
    }
  }

  void _showDeleteDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete ${user.fullName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (user.id != null) {
                ref.read(adminUsersProvider.notifier).deleteUser(user.id!, context);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
