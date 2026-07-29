import 'dart:convert';
import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/addFood_pod.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

import '../../RiverPod/favorite_pod.dart';
import '../../Utils/app_token.dart';
import '../Home/recipe_detail.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ["All Items", "Chicken Dishes", "Snacks", "Sandwiches", "Ice Cream", "Juice"];
  bool _loaded = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initUserId();
  }

  void _initUserId() async {
    _userId = await getUserId();
    if (_userId != null) {
      _fetchItems();
      _fetchFavorites();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded && _userId != null) {
      _loaded = true;
      _fetchItems();
      _fetchFavorites();
    }
  }

  void _fetchItems() {
    String category = _selectedCategoryIndex == 0 ? "" : _categories[_selectedCategoryIndex];
    Future.microtask(() {
      if (mounted) {
        ref.read(getAdminFoodProvider.notifier).getFoods(category, context);
      }
    });
  }

  void _fetchFavorites() {
    if (_userId != null) {
      Future.microtask(() {
        if (mounted) {
          ref.read(favoriteProvider.notifier).getFavorites(_userId!, context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final getFoodState = ref.watch(getAdminFoodProvider);
    final favState = ref.watch(favoriteProvider);
    List<String> favoriteIds = [];
    if (favState is GetFavoriteSuccessState) {
      favoriteIds = favState.favorites.map((e) => e.food?.id ?? "").toList();
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            CommonUI().myText(
              text: "Daily Menu",
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
            CommonUI().myText(
              text: "Crispy, Fresh, and ready for you.",
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            Gap(3.h),

            // Categories Row
            SizedBox(
              height: 5.5.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryIndex = index);
                        _fetchItems();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.fieldFill,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.fieldBorder,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: CommonUI().myText(
                            text: _categories[index],
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                            color: AppColors.textBrown,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Gap(4.h),

            // Food Items List
            if (getFoodState is GetFoodLoadingState)
              CommonUI().menuGridShimmer()
            else if (getFoodState is GetFoodSuccessSate)
              getFoodState.foods.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 3.h,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: getFoodState.foods.length,
                      itemBuilder: (context, index) {
                        final food = getFoodState.foods[index];
                        bool isFavorite = favoriteIds.contains(food.id);
                        return _buildMenuCard(food, isFavorite);
                      },
                    )
            else if (getFoodState is GetFoodErrorState)
              Center(child: Text("Error: ${getFoodState.exception}"))
            else
              const Center(child: Text("Explore our fresh menu!")),

            Gap(4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Gap(5.h),
          const Icon(Icons.restaurant_menu, size: 60, color: Colors.black12),
          Gap(2.h),
          CommonUI().myText(
            text: "No items found in this category",
            fontSize: 14.sp,
            color: Colors.black38,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(GetFoodsModel food, bool isFavorite) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(food: food),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: const Color(0xFFFAF3E7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildImageWidget(food.photo ?? ""),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      if (_userId != null && food.id != null) {
                        if (isFavorite) {
                          ref.read(favoriteProvider.notifier).removeFavorite(_userId!, food.id!, context);
                        } else {
                          ref.read(favoriteProvider.notifier).addToFavorite(_userId!, food.id!, context);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonUI().myText(
                  text: food.itemName ?? "Unnamed",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  maxLines: 1,
                ),
                CommonUI().myText(
                  text: food.category ?? "General",
                  fontSize: 11.sp,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
                Gap(1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonUI().myText(
                      text: "₹${food.price ?? 0}",
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBrown,
                    ),
                    // Container(
                    //   padding: const EdgeInsets.all(6),
                    //   decoration: BoxDecoration(
                    //     color: AppColors.primary,
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: const Icon(Icons.add, color: AppColors.textBrown, size: 18),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildImageWidget(String imageData) {
    if (imageData.isEmpty) {
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        child: const Icon(Icons.fastfood, color: Colors.grey),
      );
    }
    if (imageData.startsWith('assets/')) {
      return Image.asset(imageData, width: double.infinity, fit: BoxFit.fill);
    }
    try {
      String base64Str = imageData;
      if (imageData.contains(',')) base64Str = imageData.split(',').last;
      return Image.memory(
        base64Decode(base64Str),
        width: double.infinity,
        fit: BoxFit.fill,
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey[200],
          width: double.infinity,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }
}
