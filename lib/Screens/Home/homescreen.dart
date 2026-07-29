import 'dart:async';
import 'dart:convert';
import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/addFood_pod.dart';
import 'package:chikx/RiverPod/cart_pod.dart';
import 'package:chikx/Screens/Home/cartscreen.dart';
import 'package:chikx/Utils/app_assets.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

import '../../RiverPod/admin_deals_pod.dart';
import '../../RiverPod/favorite_pod.dart';
import '../../Utils/app_token.dart';
import 'recipe_detail.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  Timer? _carouselTimer;
  Timer? _searchDebounce;
  int _selectedCategoryIndex = 0;
  int _currentCarouselIndex = 0;
  bool _loaded = false;
  String? _userId;

  final List<String> _categories = ["All", "Chicken Dishes", "Snacks", "Sandwiches", "Ice Cream", "Juice"];

  @override
  void initState() {
    super.initState();
    _initUserId();
    _fetchDeals();
  }

  void _initUserId() async {
    _userId = await getUserId();
    if (_userId != null) {
      _fetchItems();
      _fetchCart();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded && _userId != null) {
      _loaded = true;
      _fetchItems();
      _fetchCart();
      _fetchDeals();
    }
  }

  void _fetchDeals() {
    Future.microtask(() {
      if (mounted) {
        ref.read(adminDealsProvider.notifier).fetchDeals();
      }
    });
  }

  void _fetchItems() {
    String category = _selectedCategoryIndex == 0 ? "" : _categories[_selectedCategoryIndex];
    String search = _searchController.text.trim();
    Future.microtask(() {
      if (mounted) {
        ref.read(getAdminFoodProvider.notifier).getFoods(category, context, search: search);
      }
    });
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchItems();
    });
  }

  void _fetchCart() {
    if (_userId != null) {
      Future.microtask(() {
        if (mounted) {
          ref.read(cartProvider.notifier).getCart(_userId!, context);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _startCarouselTimer(int length) {
    _carouselTimer?.cancel();
    if (length <= 1) return;
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextItem = (_currentCarouselIndex + 1) % length;
        _pageController.animateToPage(
          nextItem,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dealsState = ref.watch(adminDealsProvider);
    
    List<AdminDealModel> activeDeals = [];
    if (dealsState is AdminDealsSuccessState) {
      activeDeals = dealsState.deals.where((deal) => 
        deal.status == "published" || deal.displayStatus == "active"
      ).toList();
    }

    ref.listen(adminDealsProvider, (previous, next) {
      if (next is AdminDealsSuccessState) {
        final filtered = next.deals.where((deal) => 
          deal.status == "published" || deal.displayStatus == "active"
        ).toList();
        if (filtered.isNotEmpty) {
          _startCarouselTimer(filtered.length);
        }
      }
    });

    final getFoodState = ref.watch(getAdminFoodProvider);

    final isSearching = _searchController.text.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: CommonUI.formField(
              editingController: _searchController,
              hinttext: "What are you craving today?",
              fillColor: AppColors.white,
              borderColor: AppColors.fieldBorder,
              borderRadius: 15,
              contentsize: 14,
              icons: const Icon(Icons.search, color: AppColors.textBrown, size: 22),
              onChanged: (val) {
                setState(() {}); // Trigger rebuild to show/hide sections
                _onSearchChanged();
              },
              suffix: isSearching 
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textBrown, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      _fetchItems();
                    },
                  )
                : null,
            ),
          ),
          Gap(3.h),

          if (!isSearching) ...[
            _buildPromoCarousel(activeDeals, dealsState is AdminDealsLoadingState),
            Gap(4.h),
          ],

          // Categories Row
          SizedBox(
            height: 5.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
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
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.fieldBorder),
                      ),
                      child: Center(
                        child: CommonUI().myText(
                          text: _categories[index],
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: isSelected ? AppColors.textBrown : AppColors.textBrown.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Gap(4.h),

          // Section Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: CommonUI().myText(
              text: isSearching ? "Search Results" : "Popular Right Now",
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          Gap(2.h),

          // Food Scroll/List
          isSearching 
            ? _buildSearchGrid(getFoodState)
            : SizedBox(
                height: 38.h,
                child: _buildFoodList(getFoodState),
              ),
          
          if (!isSearching) ...[
            Gap(4.h),
            // Added Items Section
            _buildAddedItemsSection(),
            Gap(5.h),

            // Co-Founders Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: CommonUI().myText(
                text: "Meet our Co-Founders",
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            Gap(3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFounderCard("Tamilmani Maheshwari", "Vision & Operations\n Founder", AppAssets.tamil),
                _buildFounderCard("Karthikeyan Jeyasundari", "Founder", AppAssets.karthi),
              ],
            ),
            Gap(6.h),

            // Footer Section
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => const Icon(Icons.star_border, color: AppColors.textBrown, size: 20)),
                  ),
                  Gap(2.h),
                  CommonUI().myText(
                    text: "🍗 FRESHU, 😋 TASTEE,\n✨ QUALITE",
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                    color: AppColors.textBrown,
                  ),
                  Gap(2.h),
                  CommonUI().myText(
                    text: "© 2024 Chikx QSR Corp. All rights reserved.",
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            Gap(4.h),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchGrid(FoodState state) {
    if (state is GetFoodLoadingState) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 0.7,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => CommonUI().foodCardShimmer(), // Need a grid-friendly shimmer if possible, or use existing
      );
    } else if (state is GetFoodSuccessSate) {
      if (state.foods.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: CommonUI().myText(
              text: "No items match your search",
              fontSize: 14.sp,
              color: Colors.black38,
            ),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 0.65,
        ),
        itemCount: state.foods.length,
        itemBuilder: (context, index) {
          final food = state.foods[index];
          return _buildGridFoodCard(food);
        },
      );
    }
    return const SizedBox();
  }

  Widget _buildGridFoodCard(GetFoodsModel food) {
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.fieldBorder.withOpacity(0.5)),
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
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: _buildImageWidget(food.photo ?? ""),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonUI().myText(
                    text: food.itemName ?? "Unnamed",
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    maxLines: 1,
                  ),
                  CommonUI().myText(
                    text: "₹${food.price ?? 0}",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBrown,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodList(FoodState state) {
    if (state is GetFoodLoadingState) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: 3,
        itemBuilder: (context, index) => CommonUI().foodCardShimmer(),
      );
    } else if (state is GetFoodSuccessSate) {
      if (state.foods.isEmpty) {
        return Center(
          child: CommonUI().myText(
            text: "No items found",
            fontSize: 14.sp,
            color: Colors.black38,
          ),
        );
      }

      final favState = ref.watch(favoriteProvider);
      List<String> favoriteIds = [];
      if (favState is GetFavoriteSuccessState) {
        favoriteIds = favState.favorites.map((e) => e.food?.id ?? "").toList();
      }

      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: state.foods.length,
        itemBuilder: (context, index) {
          final food = state.foods[index];
          bool isFavorite = favoriteIds.contains(food.id);
          return _buildFoodCard(food, isFavorite);
        },
      );
    } else if (state is GetFoodErrorState) {
      return Center(child: Text("Error: ${state.exception}"));
    }
    return const SizedBox();
  }

  Widget _buildFoodCard(GetFoodsModel food, bool isFavorite) {
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
        width: 65.w,
      margin: EdgeInsets.only(right: 4.w, bottom: 1.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.5)),
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
                        ref.read(cartProvider.notifier).addToCart(food, _userId!, context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${food.itemName} added to cart!"),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.textBrown,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.textBrown,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: CommonUI().myText(
                    text: food.category ?? "POPULAR",
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBrown,
                  ),
                ),
                Gap(1.h),
                CommonUI().myText(
                  text: food.itemName ?? "Unnamed",
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  maxLines: 1,
                ),
                CommonUI().myText(
                  text: food.description ?? "Delicious fresh food",
                  fontSize: 11.sp,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                ),
                Gap(1.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonUI().myText(
                      text: "₹${food.price ?? 0}",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBrown,
                    ),
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

  Widget _buildAddedItemsSection() {
    final cartItems = ref.watch(cartProvider);
    if (cartItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonUI().myText(
            text: "Your Added Items",
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
          Gap(2.h),
          ...cartItems.map((item) => _buildCartItemCard(item.food)),
          Gap(2.h),
          CommonUI.buildButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
            },
            width: double.infinity,
            height: 6.5.h,
            borderradius: 15,
            gradientfirst: AppColors.primary,
            gradientsecond: AppColors.primary,
            file: Center(
              child: CommonUI().myText(
                text: "Proceed to Pay",
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(GetFoodsModel food) {
    return Container(
      width: 90.w,
      height: 9.h,
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 15.w,
              height: 15.w,
              child: _buildImageWidget(food.photo ?? ""),
            ),
          ),
          Gap(4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                  fontSize: 10.sp,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          CommonUI().myText(
            text: "₹${food.price ?? 0}",
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textBrown,
          ),
          Gap(4.w),
          GestureDetector(
            onTap: () {
              if (_userId != null && food.id != null) {
                ref.read(cartProvider.notifier).removeFromCart(food.id!, _userId!, context);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.check, size: 16, color: AppColors.textBrown),
            ),
          ),
          Gap(1.w),
        ],
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

  Widget _buildFounderCard(String name, String role, String image) {
    return Column(
      children: [
        Container(
          width: 35.w,
          height: 35.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF9F4EF),
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
            border: Border.all(color: AppColors.primary, width: 3),
          ),
        ),
        Gap(1.5.h),
        CommonUI().myText(text: name, fontSize: 14.sp, fontWeight: FontWeight.w800),
        CommonUI().myText(text: role, fontSize: 13.sp, color: AppColors.textBrown, fontWeight: FontWeight.w600, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildPromoCarousel(List<AdminDealModel> activeDeals, bool isLoading) {
    if (isLoading) {
      return Container(
        height: 28.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (activeDeals.isEmpty) {
      return Container(
        width: 95.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        height: 28.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFBBF24)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(Icons.restaurant, size: 150, color: Colors.white.withOpacity(0.2)),
            ),
            Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonUI().myText(
                    text: "Fresh & Tasty",
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBrown,
                  ),
                  Gap(1.h),
                  CommonUI().myText(
                    text: "Experience the best Chikx in town!",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBrown.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 28.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentCarouselIndex = index);
            },
            itemCount: activeDeals.length,
            itemBuilder: (context, index) {
              final deal = activeDeals[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeInOut.transform(value) * 28.h,
                      width: Curves.easeInOut.transform(value) * 100.w,
                      child: child,
                    ),
                  );
                },
                child: _buildDealCard(deal),
              );
            },
          ),
        ),
        Gap(2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(activeDeals.length, (index) {
            bool isSelected = _currentCarouselIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 24 : 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDealCard(AdminDealModel deal) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // Image with darker overlay
            Positioned.fill(
              child: Image(
                image: _getDecorationImageProvider(deal.imageUrl ?? ""),
                fit: BoxFit.fill,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Deal Info
            Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (deal.discountPercent != null && deal.discountPercent! > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CommonUI().myText(
                        text: "${deal.discountPercent}% OFF",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBrown,
                      ),
                    ),
                  // Gap(1.h),
                  // CommonUI().myText(
                  //   text: deal.title ?? "Special Deal",
                  //   fontSize: 22.sp,
                  //   fontWeight: FontWeight.w900,
                  //   color: Colors.white,
                  //   maxLines: 2,
                  // ),
                  // Gap(0.5.h),
                  // CommonUI().myText(
                  //   text: deal.category ?? "Limited Time Offer",
                  //   fontSize: 12.sp,
                  //   fontWeight: FontWeight.w600,
                  //   color: Colors.white.withOpacity(0.8),
                  // ),
                  // Gap(2.h),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(30),
                  //     ),
                  //     child: CommonUI().myText(
                  //       text: "Order Now",
                  //       fontSize: 12.sp,
                  //       fontWeight: FontWeight.w900,
                  //       color: AppColors.textBrown,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            // Tag for "Deal of Day"
            if (deal.isDealOfDay == true)
              Positioned(
                top: 2.h,
                right: 4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on, color: Colors.white, size: 14),
                      Gap(1.w),
                      CommonUI().myText(
                        text: "DEAL OF DAY",
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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

  ImageProvider _getDecorationImageProvider(String imageData) {
    if (imageData.isEmpty) {
      return const AssetImage('assets/hotelImg.png');
    }
    if (imageData.startsWith('assets/')) {
      return AssetImage(imageData);
    }
    try {
      String base64Str = imageData;
      if (imageData.contains(',')) {
        base64Str = imageData.split(',').last;
      }
      return MemoryImage(base64Decode(base64Str));
    } catch (e) {
      return const AssetImage('assets/hotelImg.png');
    }
  }
}
