import 'dart:convert';
import 'dart:io';

import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/profile_pod.dart';
import 'package:chikx/Screens/Login/login.dart';
import 'package:chikx/Screens/Profile/notification_screen.dart';
import 'package:chikx/Screens/Profile/payment_history.dart';
import 'package:chikx/Screens/Profile/personal_info.dart';
import 'package:chikx/Screens/Profile/profile_photo_screen.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/app_token.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sizer/sizer.dart';

import '../../RiverPod/favorite_pod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    String? userId = await getUserId();
    if (userId != null) {
      ref.read(getProfileProvider.notifier).getProfile(userId, context);
      ref.read(favoriteProvider.notifier).getFavorites(userId, context);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  Future<void> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      maxWidth: 512,
      maxHeight: 512,
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.textBrown,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Profile Picture'),
      ],
    );

    if (croppedFile != null) {
      _uploadImage(File(croppedFile.path));
    }
  }

  void _uploadImage(File file) async {
    String? userId = await getUserId();
    if (userId != null) {
      final bytes = await file.readAsBytes();
      String base64Image = base64Encode(bytes);

      var payload = {"profileImage": base64Image};
      ref.read(getProfileProvider.notifier).uploadProfile(userId, payload, context);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonUI().myText(
                text: "Update Profile Picture",
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
              Gap(2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imageSourceOption(
                    icon: Icons.camera_alt_outlined,
                    label: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _imageSourceOption(
                    icon: Icons.photo_library_outlined,
                    label: "Gallery",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              Gap(2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textBrown, size: 30),
          ),
          Gap(1.h),
          CommonUI().myText(text: label, fontSize: 12.sp, fontWeight: FontWeight.w700),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(getProfileProvider);
    final favState = ref.watch(favoriteProvider);

    GetProfileModel? profile;
    if (profileState is GetProfileSuccessSate) {
      profile = GetProfileModel.fromJson(profileState.data['data']);
    } else if (profileState is UploadProfileSuccessSate) {
      profile = GetProfileModel.fromJson(profileState.data['data']);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          if (profileState is GetProfileLoadingState || profileState is UploadProfileLoadingState)
            CommonUI().profileShimmer()
          else if (profile != null)
            _buildProfileHeader(profile)
          else if (profileState is GetProfileErrorState)
            Center(child: Text("Error: ${profileState.exception}"))
          else
            const Center(child: Text("No profile data available")),
          
          Gap(4.h),

          // Account Settings Section
          CommonUI().myText(
            text: "Account Settings",
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
          Gap(2.h),
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: "Personal Info",
            subtitle: "Name, Email, Mobile",
            onTap: () {
              if (profile != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalInfoScreen(profile: profile!)));
              }
            },
          ),
          Gap(2.h),
          _buildSettingsItem(
            icon: Icons.account_balance_wallet_outlined,
            title: "Payments",
            subtitle: "View transaction history",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentHistoryScreen())),
          ),
          Gap(2.h),
          _buildSettingsItem(
            icon: Icons.notifications_none_outlined,
            title: "Notifications",
            subtitle: "Manage app alerts",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
          ),
          Gap(2.h),
          _buildSettingsItem(
            icon: Icons.star_outline,
            title: "Rate Now",
            subtitle: "Share your experience with us",
            enabled: false,
            onTap: () async {
              final InAppReview inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              }
            },
          ),

          Gap(4.h),

          // Favorites Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonUI().myText(
                text: "My Favorites",
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ],
          ),
          Gap(2.h),
          SizedBox(
            height: 24.h,
            child: _buildFavoriteList(favState),
          ),
          Gap(4.h),


          // Logout Button
          GestureDetector(
            onTap: () {
              CommonUI().references();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.logoutBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: AppColors.logoutText, size: 20),
                  Gap(2.w),
                  CommonUI().myText(
                    text: "Logout",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.logoutText,
                  ),
                ],
              ),
            ),
          ),
          Gap(4.h),

          // Footer
          Center(
            child: Column(
              children: [
                CommonUI().myText(
                  text: "🍗 FRESHU, 😋 TASTEE, ✨ QUALITE",
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBrown.withValues(alpha: 0.6),
                ),
                Gap(0.5.h),
                CommonUI().myText(
                  text: "CHIKX App Version 1.0.4",
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
          Gap(4.h),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(GetProfileModel profile) {
    ImageProvider? profileImage = _getProfileImage(profile.profileImage);
    
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePhotoScreen(
                        profile: profile,
                        onUpdate: _showImageSourceDialog,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFFF9F4EF),
                    backgroundImage: profileImage,
                    child: profileImage == null ? const Icon(Icons.person, size: 55, color: AppColors.textBrown) : null,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 18, color: AppColors.textBrown),
                ),
              ),
            ],
          ),
          Gap(2.h),
          CommonUI().myText(
            text: profile.name ?? "Alex Rodriguez",
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.black,
          ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage(dynamic profileImage) {
    if (profileImage == null || profileImage == "") return null;
    String imageStr = profileImage.toString();
    if (imageStr.startsWith('http')) return NetworkImage(imageStr);
    try {
      String base64Str = imageStr;
      if (imageStr.contains(',')) base64Str = imageStr.split(',').last;
      return MemoryImage(base64Decode(base64Str));
    } catch (e) {
      return null;
    }
  }

  Widget _buildBadge(String text, {required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: CommonUI().myText(
        text: text,
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        color: color == const Color(0xFFFEF3C7) ? AppColors.textBrown : Colors.black54,
      ),
    );
  }

  Widget _buildFavoriteList(FavoriteState state) {
    if (state is GetFavoriteLoadingState) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is GetFavoriteSuccessState) {
      if (state.favorites.isEmpty) {
        return Center(
          child: CommonUI().myText(
            text: "No favorites yet",
            fontSize: 14.sp,
            color: Colors.black38,
          ),
        );
      }
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.favorites.length,
        itemBuilder: (context, index) {
          final fav = state.favorites[index];
          final food = fav.food;
          if (food == null) return const SizedBox();
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: _buildFavoriteItem(
              food.photo ?? "",
              food.itemName ?? "Unnamed",
              "₹${food.price ?? 0}",
            ),
          );
        },
      );
    } else if (state is GetFavoriteErrorState) {
      return Center(child: Text("Error: ${state.exception}"));
    }
    return const SizedBox();
  }

  Widget _buildFavoriteItem(String image, String title, String price) {
    return Container(
      width: 55.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildImageWidget(image),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 18),
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
                CommonUI().myText(text: title, fontSize: 13.sp, fontWeight: FontWeight.w800, maxLines: 1),
                CommonUI().myText(text: price, fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textBrown),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageData) {
    if (imageData.isEmpty) {
      return Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, color: Colors.grey));
    }
    if (imageData.startsWith('assets/')) return Image.asset(imageData, fit: BoxFit.fill);
    if (imageData.startsWith('http')) return Image.network(imageData, fit: BoxFit.fill, errorBuilder: (c, e, s) => Container(color: Colors.grey[200]));
    try {
      String base64Str = imageData;
      if (imageData.contains(',')) base64Str = imageData.split(',').last;
      return Image.memory(base64Decode(base64Str), fit: BoxFit.fill, errorBuilder: (c, e, s) => Container(color: Colors.grey[200]));
    } catch (e) {
      return Container(color: Colors.grey[200]);
    }
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF3E7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black45, size: 24),
              ),
              Gap(4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonUI().myText(text: title, fontSize: 14.sp, fontWeight: FontWeight.w800),
                    CommonUI().myText(text: subtitle, fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black38),
                  ],
                ),
              ),
              if (enabled) const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
