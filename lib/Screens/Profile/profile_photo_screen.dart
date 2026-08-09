import 'dart:convert';
import 'package:chikx/Models/app_model.dart';
import 'package:chikx/RiverPod/profile_pod.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

import '../../Provider/providers.dart';

class ProfilePhotoScreen extends ConsumerWidget {
  final GetProfileModel profile;
  final VoidCallback onUpdate;

  const ProfilePhotoScreen({super.key, required this.profile, required this.onUpdate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for profile updates to keep this screen reactive
    final profileState = ref.watch(getProfileProvider);
    GetProfileModel currentProfile = profile;
    
    if (profileState is GetProfileSuccessSate) {
      currentProfile = GetProfileModel.fromJson(profileState.data['data']);
    } else if (profileState is UploadProfileSuccessSate) {
      currentProfile = GetProfileModel.fromJson(profileState.data['data']);
    }

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBrown),
            onPressed: () => Navigator.pop(context),
          ),
          title: CommonUI().myText(
            text: "Profile Photo",
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const Spacer(),
            Center(
              child: Container(
                width: 85.w,
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: _buildImageWidget(currentProfile.profileImage),
                ),
              ),
            ),
            Gap(4.h),
            CommonUI().myText(
              text: "MAIN PROFILE IDENTITY",
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
              letterSpacing: 1.2,
            ),
            Gap(0.5.h),
            CommonUI().myText(
              text: "Current Active Profile Image",
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black26,
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CommonUI.buildButton(
                    onPressed: onUpdate,
                    width: double.infinity,
                    height: 6.5.h,
                    borderradius: 15,
                    file: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: AppColors.textBrown),
                        Gap(3.w),
                        CommonUI().myText(
                          text: "Change Photo",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBrown,
                        ),
                      ],
                    ),
                  ),
                  Gap(2.h),
                  GestureDetector(
                    onTap: () {
                      // Implementation for share if needed
                    },
                    child: Container(
                      width: double.infinity,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_outlined, size: 20, color: Colors.black54),
                          Gap(2.w),
                          CommonUI().myText(
                            text: "Share",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(dynamic profileImage) {
    if (profileImage == null || profileImage == "") { 
      return Container(
        color: const Color(0xFFFAF3E7),
        child: const Icon(Icons.person, size: 100, color: AppColors.textBrown),
      );
    }
    String imageStr = profileImage.toString();
    if (imageStr.startsWith('http')) {
      return Image.network(imageStr, fit: BoxFit.fill, errorBuilder: (c, e, s) => _errorWidget());
    }
    try {
      String base64Str = imageStr;
      if (imageStr.contains(',')) base64Str = imageStr.split(',').last;
      return Image.memory(base64Decode(base64Str), fit: BoxFit.fill, errorBuilder: (c, e, s) => _errorWidget());
    } catch (e) {
      return _errorWidget();
    }
  }

  Widget _errorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
    );
  }
}
