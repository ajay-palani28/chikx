import 'dart:convert';
import 'dart:io';
import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/admin_deals_pod.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class SpecialOffersScreen extends ConsumerStatefulWidget {
  const SpecialOffersScreen({super.key});

  @override
  ConsumerState<SpecialOffersScreen> createState() => _SpecialOffersScreenState();
}

class _SpecialOffersScreenState extends ConsumerState<SpecialOffersScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  File? _offerImage;
  String? _existingImageUrl;
  bool _isDealOfTheDay = false;
  bool _pushNotification = true;
  AdminDealModel? _editingDeal;
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      Future.microtask(() => ref.read(adminDealsProvider.notifier).fetchDeals());
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  Future<void> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2),
      maxWidth: 800, // Reasonable max width for banners
      maxHeight: 533,
      compressQuality: 60, // Significantly reduce size
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Offer Banner',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.textBrown,
          statusBarColor: AppColors.primary,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.ratio3x2,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Offer Banner'),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _offerImage = File(croppedFile.path);
        _existingImageUrl = null;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _editingDeal = null;
      _titleController.clear();
      _discountController.clear();
      _categoryController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _offerImage = null;
      _existingImageUrl = null;
      _isDealOfTheDay = false;
      _pushNotification = true;
    });
  }

  void _loadDealForEditing(AdminDealModel deal) {
    setState(() {
      _editingDeal = deal;
      _titleController.text = deal.title ?? "";
      _discountController.text = deal.discountPercent?.toString() ?? "";
      _categoryController.text = deal.category ?? "";
      _startDateController.text = deal.startDate ?? "";
      _endDateController.text = deal.endDate ?? "";
      _existingImageUrl = deal.imageUrl;
      _offerImage = null;
      _isDealOfTheDay = deal.isDealOfDay ?? false;
      _pushNotification = deal.pushNotification ?? true;
    });
  }

  Future<void> _handleSave(String status) async {
    String? base64Image;
    if (_offerImage != null) {
      List<int> imageBytes = await _offerImage!.readAsBytes();
      base64Image = base64Encode(imageBytes);
      
      // Safety check for large payloads (Cloudflare D1 limit)
      if (base64Image.length > 500000) { // ~500KB limit for safety
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Image size too large even after compression. Try a different image."))
         );
         return;
      }
    } else {
      base64Image = _existingImageUrl;
    }

    final deal = AdminDealModel(
      id: _editingDeal?.id,
      title: _titleController.text.isEmpty ? "Offer Banner" : _titleController.text,
      discountPercent: int.tryParse(_discountController.text) ?? 0,
      category: _categoryController.text.isEmpty ? "General" : _categoryController.text,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
      imageUrl: base64Image,
      isDealOfDay: _isDealOfTheDay,
      pushNotification: _pushNotification,
      status: status,
    );

    if (deal.imageUrl == null || deal.imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload an image")));
      return;
    }

    if (deal.startDate == null || deal.startDate!.isEmpty || deal.endDate == null || deal.endDate!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select start and end dates")));
      return;
    }

    await ref.read(adminDealsProvider.notifier).upsertDeal(deal, context);
    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final dealsState = ref.watch(adminDealsProvider);

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
          text: "Admin: Special Offers",
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonUI().myText(
                  text: _editingDeal != null ? "Edit Deal" : "Create New Deal",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                ),
                Gap(1.h),
                CommonUI().myText(
                  text: "Upload a banner (3:2) and optionally provide offer details. published offers appear in the home carousel.",
                  fontSize: 12.sp,
                  color: Colors.black54,
                  maxLines: 0,
                ),
                Gap(4.h),

                // Image Upload section - 3:2 Aspect Ratio recommendation
                _buildImageUploadSection(),
                Gap(3.h),

                // Form Fields Card (Optional fields according to user)
                _buildFormCard(),
                Gap(3.h),

                // Validity Period Card
                _buildValidityCard(),
                Gap(3.h),

                // Visibility Settings
                _buildVisibilitySettings(),
                Gap(4.h),

                Row(
                  children: [
                    Expanded(
                      child: CommonUI.buildButton(
                        height: 5.h,
                        onPressed: () => _handleSave("published"),
                        borderradius: 12,
                        file: Center(
                          child: CommonUI().myText(
                            text: "Publish Offer",
                            fontWeight: FontWeight.w800,
                            color: AppColors.textBrown,
                          ),
                        ),
                      ),
                    ),
                    Gap(4.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleSave("draft"),
                        child: Container(
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Center(
                            child: CommonUI().myText(
                              text: "Save as Draft",
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_editingDeal != null) ...[
                  Gap(2.h),
                  TextButton(
                    onPressed: _resetForm,
                    child: const Center(child: Text("Cancel Editing", style: TextStyle(color: Colors.red))),
                  ),
                ],
                Gap(5.h),

                // Active Deals List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonUI().myText(text: "Managed Deals", fontSize: 18.sp, fontWeight: FontWeight.w900),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: () => ref.read(adminDealsProvider.notifier).fetchDeals(),
                    ),
                  ],
                ),
                CommonUI().myText(text: "Published and draft offers", fontSize: 11.sp, color: Colors.black38),
                Gap(2.h),

                _buildDealsList(dealsState),
                Gap(5.h),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildDealsList(AdminDealsState state) {
    if (state is AdminDealsLoadingState) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    } else if (state is AdminDealsErrorState) {
      return Center(child: Text(state.message));
    } else if (state is AdminDealsSuccessState || state is AdminDealsActionLoadingState) {
      final deals = state is AdminDealsSuccessState ? state.deals : (state as AdminDealsActionLoadingState).deals;
      if (deals.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: deals.length,
        itemBuilder: (context, index) {
          return _buildDealCard(deals[index]);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F4EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_offer_outlined, size: 40, color: Colors.black26),
          Gap(1.h),
          CommonUI().myText(text: "No deals found", fontWeight: FontWeight.w800, color: Colors.black45),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel("Offer Title (Optional)"),
          CommonUI.formField(editingController: _titleController, hinttext: "e.g., Weekend Bonanza", borderRadius: 10, contentsize: 12),
          Gap(2.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("Discount %"),
                    CommonUI.formField(
                      editingController: _discountController, 
                      hinttext: "0", 
                      keyboardType: TextInputType.number,
                      suffix: Padding(padding: const EdgeInsets.only(top: 10), child: Text("%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))), 
                      borderRadius: 10, 
                      contentsize: 12,
                    ),
                  ],
                ),
              ),
              Gap(4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("Category"),
                    CommonUI.formField(editingController: _categoryController, hinttext: "e.g., Chicken", borderRadius: 10, contentsize: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValidityCard() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black45),
              Gap(2.w),
              CommonUI().myText(text: "Validity Period", fontWeight: FontWeight.w800),
            ],
          ),
          Gap(2.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("START DATE", size: 9),
                    CommonUI.formField(
                      editingController: _startDateController, 
                      hinttext: "yyyy-mm-dd", 
                      readOnly: true, 
                      onTap: () => _selectDate(context, _startDateController),
                      borderRadius: 10,
                      contentsize: 10.sp,
                      suffix: const Icon(Icons.calendar_month, size: 16),
                    ),
                  ],
                ),
              ),
              Gap(4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("END DATE", size: 9),
                    CommonUI.formField(
                      editingController: _endDateController, 
                      hinttext: "yyyy-mm-dd", 
                      readOnly: true, 
                      onTap: () => _selectDate(context, _endDateController),
                      borderRadius: 10,
                      contentsize: 10.sp,
                      suffix: const Icon(Icons.calendar_month, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonUI().myText(text: "Offer Banner (3:2 Ratio)", fontWeight: FontWeight.w800, fontSize: 12.sp),
          Gap(2.h),
          AspectRatio(
            aspectRatio: 3 / 2,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F0E6),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.fieldBorder, style: BorderStyle.solid),
                  image: _offerImage != null 
                    ? DecorationImage(image: FileImage(_offerImage!), fit: BoxFit.cover)
                    : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                      ? DecorationImage(image: _getDecorationImageProvider(_existingImageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: (_offerImage == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty))
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textBrown),
                        Gap(1.h),
                        CommonUI().myText(text: "Upload Offer Banner", fontWeight: FontWeight.w800, color: AppColors.textBrown),
                        CommonUI().myText(text: "Recommended 3:2 aspect ratio", fontSize: 9.sp, color: Colors.black38),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, size: 18, color: AppColors.textBrown),
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getDecorationImageProvider(String imageData) {
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
      return const AssetImage('assets/placeholder.png');
    }
  }

  Widget _buildVisibilitySettings() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonUI().myText(text: "Visibility Settings", fontWeight: FontWeight.w800, fontSize: 12.sp),
          Gap(2.h),
          Row(
            children: [
              const Icon(Icons.stars_outlined, size: 20, color: AppColors.textBrown),
              Gap(3.w),
              Expanded(child: CommonUI().myText(text: "Deal of the Day", fontWeight: FontWeight.w700)),
              Switch(
                value: _isDealOfTheDay, 
                onChanged: (v) => setState(() => _isDealOfTheDay = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const Divider(height: 1, color: Colors.black12),
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.textBrown),
              Gap(3.w),
              Expanded(child: CommonUI().myText(text: "Push Notification", fontWeight: FontWeight.w700)),
              Switch(
                value: _pushNotification, 
                onChanged: (v) => setState(() => _pushNotification = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(AdminDealModel deal) {
    bool isActive = deal.displayStatus == 'active';
    bool isDraft = deal.status == 'draft';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 3 / 1.5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: deal.imageUrl != null && deal.imageUrl!.isNotEmpty
                    ? Image(image: _getDecorationImageProvider(deal.imageUrl!), fit: BoxFit.cover)
                    : Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 50, color: Colors.black12)),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDraft ? Colors.grey : (isActive ? Colors.green : Colors.orange),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: CommonUI().myText(
                        text: isDraft ? "DRAFT" : (deal.displayStatus?.toUpperCase() ?? "UNKNOWN"), 
                        fontSize: 8.sp, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white,
                      ),
                    ),
                    if (deal.isDealOfDay == true) ...[
                      Gap(2.w),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.star, size: 12, color: AppColors.textBrown),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonUI().myText(text: deal.title ?? "Untitled Offer", fontSize: 14.sp, fontWeight: FontWeight.w800),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.black26),
                    Gap(1.w),
                    CommonUI().myText(text: "${deal.startDate} to ${deal.endDate}", fontSize: 10.sp, color: Colors.black26),
                  ],
                ),
                Gap(1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonUI().myText(
                      text: deal.discountPercent != null && deal.discountPercent! > 0 ? "${deal.discountPercent}% OFF" : "SPECIAL OFFER", 
                      fontSize: 16.sp, 
                      fontWeight: FontWeight.w900, 
                      color: AppColors.textBrown,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black45),
                          onPressed: () => _loadDealForEditing(deal),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                          onPressed: () => _showDeleteDialog(deal),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AdminDealModel deal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Deal"),
        content: Text("Are you sure you want to delete '${deal.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (deal.id != null) {
                ref.read(adminDealsProvider.notifier).deleteDeal(deal.id!, context);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {double size = 11}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: CommonUI().myText(
        text: label,
        fontSize: size.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.black,
      ),
    );
  }
}
