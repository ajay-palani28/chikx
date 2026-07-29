import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: CommonUI().myText(
          text: "Notifications",
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_paused_outlined,
                  size: 60.sp,
                  color: AppColors.primary,
                ),
              ),
              Gap(4.h),
              CommonUI().myText(
                text: "Coming Soon!",
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textBrown,
              ),
              Gap(2.h),
              CommonUI().myText(
                text: "We're working on something exciting. You'll soon be able to see all your order updates and special offers here!",
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                textAlign: TextAlign.center,
                maxLines: 0,
                overflow: TextOverflow.visible
              ),
              Gap(6.h),
              CommonUI.buildButton(
                onPressed: () => Navigator.pop(context),
                width: 50.w,
                height: 6.h,
                borderradius: 15,
                gradientfirst: AppColors.primary,
                gradientsecond: AppColors.primary,
                file: Center(
                  child: CommonUI().myText(
                    text: "Go Back",
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
}
