import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

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
                // Illustration or Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.engineering_rounded,
                    size: 25.w,
                    color: AppColors.primary,
                  ),
                ),
                Gap(5.h),
                // Title
                CommonUI().myText(
                  text: "Under Maintenance",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                Gap(2.h),
                // Description
                CommonUI().myText(
                  text: "We are currently performing scheduled maintenance to improve our services. We'll be back online shortly!",
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  textAlign: TextAlign.center,
                  maxLines: 0,
                ),
                const Spacer(),
                // Support Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonUI().myText(
                      text: "Need urgent help? ",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black45,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle contact support
                      },
                      child: CommonUI().myText(
                        text: "Contact Support",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBrown,
                      ),
                    ),
                  ],
                ),
                Gap(6.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
