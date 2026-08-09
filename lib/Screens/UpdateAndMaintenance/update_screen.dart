import 'package:chikx/Utils/app_assets.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  Future<void> _launchUpdate() async {
    final String url = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.chikx.app' // Replace with your actual package name
        : 'https://apps.apple.com/app/id123456789'; // Replace with your actual app id
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Icon or Logo
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update,
                    size: 25.w,
                    color: AppColors.primary,
                  ),
                ),
                Gap(5.h),
                // Title
                CommonUI().myText(
                  text: "Update Available!",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                Gap(2.h),
                // Description
                CommonUI().myText(
                  text: "A newer version of ChikX is available with new features and improvements. Please update to continue.",
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  textAlign: TextAlign.center,
                  maxLines: 0,
                ),
                const Spacer(),
                // Update Button
                CommonUI.buildButton(
                  onPressed: _launchUpdate,
                  width: 100.w,
                  height: 6.h,
                  borderradius: 12,
                  gradientfirst: AppColors.primary,
                  gradientsecond: AppColors.primary,
                  file: Center(
                    child: CommonUI().myText(
                      text: "Update Now",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBrown,
                    ),
                  ),
                ),
                Gap(2.h),
                // Optional: Secondary button for "Later" if not mandatory
                /*GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CommonUI().myText(
                    text: "Not Now",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),*/
                Gap(4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
