import 'dart:convert';
import 'dart:io';

import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/profile_pod.dart';
import 'package:chikx/Screens/Login/login.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/app_token.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadProfile();
    }
  }

  void _loadProfile() async {
    String? userId = await getUserId();
    if (userId != null) {
      Future.microtask(() {
        if (mounted) {
          ref.read(getProfileProvider.notifier).getProfile(userId, context);
        }
      });
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Profile Header
          if (profileState is GetProfileLoadingState || profileState is UploadProfileLoadingState)
            CommonUI().profileShimmer()
          else if (profileState is GetProfileSuccessSate || profileState is UploadProfileSuccessSate)
            _buildAdminProfileHeader(GetProfileModel.fromJson(
                profileState is GetProfileSuccessSate ? profileState.data['data'] : (profileState as UploadProfileSuccessSate).data['data']))
          else if (profileState is GetProfileErrorState)
            Center(child: Text("Error: ${profileState.exception}"))
          else
            const Center(child: Text("No profile data available")),
          
          Gap(4.h),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard("Revenue", "₹4.2k", Icons.payments_outlined, isPrimary: true),
              _buildStatCard("Staff", "12", Icons.people_outline),
              _buildStatCard("Orders", "84", Icons.shopping_bag_outlined),
              _buildStatCard("Rating", "4.8", Icons.star_outline),
            ],
          ),
          Gap(4.h),

          // Business Info Card
          _buildInfoCard(
            title: "Business Info",
            subtitle: "Location, hours, and branding",
            actionText: "Edit",
            icon: Icons.storefront_outlined,
            content: Column(
              children: [
                _buildInfoRow(Icons.location_on_outlined, "123 Flavor Street\nDowntown District, NY"),
                Gap(2.h),
                _buildInfoRow(Icons.access_time, "Open Daily\n09:00 AM - 10:00 PM"),
              ],
            ),
          ),
          Gap(3.h),

          // Staff Management Card
          _buildInfoCard(
            title: "Staff Management",
            subtitle: "Manage permissions and roles",
            actionText: "Add Staff",
            isActionPill: true,
            icon: Icons.assignment_ind_outlined,
            content: Column(
              children: [
                _buildStaffTile("Marcus Chen", "Head Chef", "MANAGER"),
                Gap(1.5.h),
                _buildStaffTile("Sarah Miller", "Supervisor", "EDITOR"),
              ],
            ),
          ),
          Gap(3.h),

          // Danger Zone
          _buildDangerZone(),  
          Gap(4.h),
        ],
      ),
    );
  }

  Widget _buildAdminProfileHeader(GetProfileModel profile) {
    ImageProvider? profileImage = _getProfileImage(profile.profileImage);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.white,
                backgroundImage: profileImage,
                child: profileImage == null ? const Icon(Icons.person, size: 35, color: AppColors.textBrown) : null,
              ),
            ),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: AppColors.textBrown),
              ),
            ),
          ],
        ),
        Gap(4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonUI().myText(
                text: "Admin: ${profile.name ?? 'Manager'}",
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
              CommonUI().myText(
                text: profile.email ?? "Manage restaurant operations",
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        _buildSwitchToUserButton(),
      ],
    );
  }

  ImageProvider? _getProfileImage(dynamic profileImage) {
    if (profileImage == null || profileImage == "") return null;

    String imageStr = profileImage.toString();

    if (imageStr.startsWith('http')) {
      return NetworkImage(imageStr);
    }

    try {
      String base64Str = imageStr;
      if (imageStr.contains(',')) {
        base64Str = imageStr.split(',').last;
      }
      return MemoryImage(base64Decode(base64Str));
    } catch (e) {
      return null;
    }
  }

  Widget _buildSwitchToUserButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: const Color(0xFF5D5D5D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.visibility_outlined, color: Colors.white, size: 16),
          Gap(2.w),
          CommonUI().myText(
            text: "Switch to\nUser",
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            lineHeight: 1.1,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {bool isPrimary = false}) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : const Color(0xFFF9F4EF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.textBrown, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonUI().myText(text: label, fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black54),
              CommonUI().myText(text: value, fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    String? actionText,
    bool isActionPill = false,
    required Widget content,
  }) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F4EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppColors.textBrown, size: 22),
                  ),
                  Gap(3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonUI().myText(text: title, fontSize: 15.sp, fontWeight: FontWeight.w800),
                      CommonUI().myText(text: subtitle, fontSize: 11.sp, color: Colors.black54, fontWeight: FontWeight.w500),
                    ],
                  ),
                ],
              ),
              if (actionText != null)
                isActionPill
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CommonUI().myText(text: actionText, fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppColors.textBrown),
                      )
                    : CommonUI().myText(text: actionText, fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppColors.textBrown),
            ],
          ),
          Gap(3.h),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black45),
        Gap(3.w),
        Expanded(
          child: CommonUI().myText(text: text, fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87, maxLines: 0),
        ),
      ],
    );
  }

  Widget _buildStaffTile(String name, String role, String tag) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFF9F4EF),
          child: Icon(Icons.person, color: AppColors.textBrown, size: 20),
        ),
        Gap(3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonUI().myText(text: name, fontSize: 12.sp, fontWeight: FontWeight.w800),
              CommonUI().myText(text: role, fontSize: 11.sp, color: Colors.black54, fontWeight: FontWeight.w500),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F4EF),
            borderRadius: BorderRadius.circular(5),
          ),
          child: CommonUI().myText(text: tag, fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonUI().myText(text: title, fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black87),
        Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(
            value: value,
            activeColor: AppColors.textBrown,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingActionRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonUI().myText(text: title, fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black87),
        Row(
          children: [
            CommonUI().myText(text: value, fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.black45),
            Gap(1.w),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
          ],
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonUI().myText(text: "Danger Zone", fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.red[800]),
        Gap(1.h),
        CommonUI().myText(
          text: "Irreversible actions that affect your entire business setup.",
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.red[800]!.withOpacity(0.7),
          maxLines: 0,
        ),
        Gap(3.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red[800]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CommonUI().myText(text: "Clear Data", fontSize: 12.sp, fontWeight: FontWeight.w800, color: Colors.red[800]),
            ),
            Gap(6.w),
            GestureDetector(
              onTap: () {
                CommonUI().references();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
              },
              child: CommonUI().myText(text: "Logout", fontSize: 12.sp, fontWeight: FontWeight.w800, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}
