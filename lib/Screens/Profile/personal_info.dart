import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

class PersonalInfoScreen extends StatelessWidget {
  final GetProfileModel profile;

  const PersonalInfoScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
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
            text: "Personal Info",
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(5.w),
          child: Column(
            children: [
              _buildInfoTile("Full Name", profile.name ?? "Not set", Icons.person_outline),
              _buildInfoTile("Email Address", profile.email ?? "Not set", Icons.email_outlined),
              _buildInfoTile("Phone Number", profile.phone ?? "Not set", Icons.phone_android_outlined),
              Gap(4.h),
              CommonUI.buildButton(
                onPressed: () => Navigator.pop(context),
                width: double.infinity,
                height: 6.5.h,
                file: Center(
                  child: CommonUI().myText(
                    text: "Done",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textBrown, size: 22),
          ),
          Gap(4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonUI().myText(
                  text: label,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
                CommonUI().myText(
                  text: value,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
