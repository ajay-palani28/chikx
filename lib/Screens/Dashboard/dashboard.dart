import 'package:chikx/Screens/Home/cartscreen.dart';
import 'package:chikx/Screens/Home/homescreen.dart';
import 'package:chikx/Screens/Menu/menuscreen.dart';
import 'package:chikx/Screens/Support/supportscreen.dart';
import 'package:chikx/Screens/Profile/profilescreen.dart';
import 'package:chikx/Utils/app_assets.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:chikx/RiverPod/cart_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

import '../../Provider/providers.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int _currentIndex = 0; // Default to Profile based on user request context

  final List<Widget> _screens = [
    const HomeScreen(),
    const MenuScreen(),
    const SupportScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isMenuScreen = _currentIndex == 1;
    bool isSupportScreen = _currentIndex == 2;
    bool isProfileScreen = _currentIndex == 3;

    final cartItems = ref.watch(cartProvider);
    int cartCount = cartItems.fold(0, (sum, item) => sum + item.quantity);

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
            leading: (isSupportScreen || isProfileScreen || isMenuScreen)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textBrown),
                    onPressed: () => setState(() => _currentIndex = 0),
                  )
                : const Icon(Icons.home,size: 35, color: AppColors.primary),
            centerTitle: true,
            title: isProfileScreen
                ?  CommonUI().myText(
              text: "CHIKX Profile",
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            )
                : isSupportScreen
                ? CommonUI().myText(
                    text: "CHIKX Support",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  )
                : isMenuScreen
                ? CommonUI().myText(
                    text: "CHIKX Menu",
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
                  )
                : Column(
                    children: [
                      CommonUI().myText(
                        text: "CHIKX",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
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
            actions: [
              if (isSupportScreen || isProfileScreen || isMenuScreen)
                Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: _buildSmallLogo(),
                )
              else
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.black),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                      },
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: CommonUI().myText(
                            text: "$cartCount",
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                  ],
                ),
            ],
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildProfileAppBarTitle() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E4D0),
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage('assets/chikx_logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSmallLogo() {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E4D0),
        borderRadius: BorderRadius.circular(8),
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
          _buildNavItem(0, Icons.home_outlined, "Home"),
          _buildNavItem(1, Icons.restaurant_menu_outlined, "Menu"),
          _buildNavItem(2, Icons.headset_mic_outlined, "Support"),
          _buildNavItem(3, Icons.person_outline, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.person : icon,
              color: isSelected ? AppColors.textBrown : Colors.black45,
              size: 24,
            ),
            if (isSelected) ...[
              Gap(2.w),
              CommonUI().myText(
                text: label,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textBrown,
              ),
            ] else ...[
              // We can keep it simple as per image where active is a pill
            ],
          ],
        ),
      ),
    );
  }
}
