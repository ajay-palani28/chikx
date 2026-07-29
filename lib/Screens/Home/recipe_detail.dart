import 'dart:convert';
import 'package:chikx/Models/app_model.dart';
import 'package:chikx/RiverPod/cart_pod.dart';
import 'package:chikx/Screens/Home/cartscreen.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/app_token.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

import '../../Provider/providers.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final GetFoodsModel food;

  const RecipeDetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    int cartCount = cartItems.fold(0, (sum, item) => sum + item.quantity);

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: CommonUI().myText(
            text: "ChikX",
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textBrown,
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
              },
              child: Stack(
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
            ),
            Gap(2.w),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Gap(1.h),
              // Food Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 25.h,
                    width: 90.w,
                    child: _buildImageWidget(food.photo ?? ""),
                  ),
                ),
              ),
              Gap(2.h),

              // Content Card
              Center(
                child: Container(
                  width: 90.w,
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: CommonUI().myText(
                          text: "RECIPE DETAIL",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBrown,
                        ),
                      ),
                      Gap(1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonUI().myText(
                                  text: food.itemName ?? "Unnamed",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.black,
                                ),
                                CommonUI().myText(
                                  text: "FRESHU, TASTEE, QUALITE",
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black38,
                                  letterSpacing: 1,
                                ),
                              ],
                            ),
                          ),
                          CommonUI().myText(
                            text: "₹${food.price ?? 0}",
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBrown,
                          ),
                        ],
                      ),
                      Gap(1.h),
                      const Divider(color: Colors.black12),
                      Gap(1.h),
                      Row(
                        children: [
                          const Icon(Icons.restaurant_menu, color: AppColors.textBrown, size: 18),
                          Gap(2.w),
                          CommonUI().myText(
                            text: "The Secret Recipe",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ],
                      ),
                      Gap(1.h),
                      CommonUI().myText(
                        text: food.description ?? "Our legendary ${food.itemName} starts with premium ingredients, marinated for 24 hours and cooked to perfection to achieve that iconic, satisfying crunch.",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        height: 1.5,
                        maxLines: 0,
                      ),
                      Gap(2.h),
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: [
                          _buildTag("Golden Marinated"),
                          _buildTag("12 Secret Spices"),
                          _buildTag("Buttermilk Batter"),
                        ],
                      ),
                      Gap(3.h),
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9F0),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow("Cook Time", "12 Mins"),
                            Gap(1.h),
                            _buildInfoRow("Calories", "320 kcal"),
                            Gap(1.h),
                            _buildInfoRow("Spice Level", "🔥🔥"),
                          ],
                        ),
                      ),
                      Gap(2.h),
                      CommonUI.buildButton(
                        onPressed: () async {
                          String? userId = await getUserId();
                          if (userId != null) {
                            ref.read(cartProvider.notifier).addToCart(food, userId, context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${food.itemName} added to cart!"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        width: double.infinity,
                        height: 5.h,
                        borderradius: 12,
                        gradientfirst: AppColors.primary,
                        gradientsecond: AppColors.primary,
                        file: Center(
                          child: CommonUI().myText(
                            text: "Add to Cart",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textBrown,
                          ),
                        ),
                      ),
                      Gap(1.5.h),
                      CommonUI.buildButton(
                        onPressed: () async {
                          String? userId = await getUserId();
                          if (userId != null) {
                            ref.read(cartProvider.notifier).addToCart(food, userId, context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                          }
                        },
                        width: double.infinity,
                        height: 5.h,
                        borderradius: 12,
                        gradientfirst: AppColors.black,
                        gradientsecond: AppColors.black,
                        file: Center(
                          child: CommonUI().myText(
                            text: "Buy Now",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E7D5).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CommonUI().myText(
        text: label,
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textBrown,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonUI().myText(text: label, fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
        CommonUI().myText(text: value, fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.black),
      ],
    );
  }

  Widget _buildSuggestedItem(String name, String price) {
    return Container(
      width: 40.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Container(
                color: const Color(0xFFFAF3E7),
                width: double.infinity,
                child: const Icon(Icons.fastfood, color: AppColors.primary, size: 35),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonUI().myText(text: name, fontSize: 10.sp, fontWeight: FontWeight.w800, maxLines: 1),
                CommonUI().myText(text: price, fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppColors.textBrown),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageData) {
    if (imageData.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.fastfood, color: Colors.grey, size: 50),
      );
    }
    if (imageData.startsWith('assets/')) {
      return Image.asset(imageData, fit: BoxFit.fill);
    }
    try {
      String base64Str = imageData;
      if (imageData.contains(',')) base64Str = imageData.split(',').last;
      return Image.memory(
        base64Decode(base64Str),
        fit: BoxFit.fill,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }
}
