import 'package:chikx/Screens/Admin/AdminHome/homescreen.dart';
import 'package:chikx/Screens/Admin/AdminSupport/conversation_list.dart';
import 'package:chikx/Screens/Admin/AdminMenu/menuscreen.dart';
import 'package:chikx/Screens/Admin/AdminProfile/profilescreen.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

class Admindashboard extends StatefulWidget {
  const Admindashboard({super.key});

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const AdminMenuScreen(),
    const AdminConversationListScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isSupportScreen = _currentIndex == 2;
    bool isProfileScreen = _currentIndex == 3;
    bool isUsersScreen = _currentIndex == 1;

    return PopScope(
      canPop: false,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          backgroundColor: AppColors.bgColor,
          appBar: AppBar(
            backgroundColor: AppColors.bgColor,
            elevation: 0,
            toolbarHeight: 10.h,
            leadingWidth: (isSupportScreen || isProfileScreen || isUsersScreen) ? 12.w : null,
            centerTitle: isProfileScreen || isSupportScreen || isUsersScreen ? false : true,
            title: isSupportScreen
                ? CommonUI().myText(
                    text: "Support Dashboard",
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBrown,
                  )
                : isUsersScreen
                    ? CommonUI().myText(
                        text: "Users List",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBrown,
                      )
                    : isProfileScreen
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSmallLogoBox(),
                                Gap(0.5.h),
                                CommonUI().myText(
                                  text: "🍗 FRESHU, 😋 TASTEE, ✨ QUALITE",
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textBrown.withOpacity(0.8),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              _buildSmallLogoBox(),
                              Gap(3.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonUI().myText(
                                    text: "CHIKX",
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.black,
                                  ),
                                  CommonUI().myText(
                                    text: "🍗 FRESHU, 😋 TASTEE, ✨ QUALITE",
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textBrown.withOpacity(0.8),
                                  ),
                                ],
                              ),
                            ],
                          ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFF9F4EF),
                  child: Icon(Icons.person, color: AppColors.textBrown, size: 24),
                ),
              ),
            ],
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildSmallLogoBox() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        image: const DecorationImage(
          image: AssetImage('assets/chikx_logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 8.h,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home, "Home"),
          _buildNavItem(1, Icons.people_outline, Icons.people, "Users"),
          _buildNavItem(2, Icons.headset_mic_outlined, Icons.headset_mic, "Support"),
          _buildNavItem(3, Icons.person_outline, Icons.person, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: isSelected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(activeIcon, color: AppColors.textBrown, size: 22),
                  Gap(2.w),
                  CommonUI().myText(
                    text: label,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBrown,
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(inactiveIcon, color: Colors.black45, size: 24),
                  Gap(0.2.h),
                  CommonUI().myText(
                    text: label,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ],
              ),
      ),
    );
  }
}
