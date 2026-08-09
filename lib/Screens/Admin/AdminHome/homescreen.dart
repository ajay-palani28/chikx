import 'dart:convert';
import 'dart:io';

import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/addFood_pod.dart';
import 'package:chikx/Screens/Admin/AdminHome/special_offers.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _addCategories = ["Chicken Dishes", "Snacks", "Sandwiches", "Ice Cream", "Juice"];
  String? _selectedCategory;
  GetFoodsModel? _editingFood;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loaded) {
      _loaded = true;
      Future.microtask(() {
        if (mounted) {
          ref.read(getAdminFoodProvider.notifier).getFoods("", context);
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
          toolbarTitle: 'Crop Food Image',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.textBrown,
          statusBarColor: AppColors.primary,
          activeControlsWidgetColor: AppColors.primary,
          hideBottomControls: false,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(title: 'Crop Food Image'),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonUI().myText(
                    text: "Select Image Source",
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
          CommonUI().myText(
            text: label,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(foodProvider, (previous, next) {
      if (next is AddFoodSuccessSate) {
        bool wasEditing = _editingFood != null;
        _itemNameController.clear();
        _categoryController.clear();
        _priceController.clear();
        _descController.clear();
        setState(() {
          _imageFile = null;
          _selectedCategory = null;
          _editingFood = null;
        });
        // Refresh the list after adding
        ref.read(getAdminFoodProvider.notifier).getFoods("", context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasEditing ? "Food item updated successfully!" : "Food item added successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    final getFoodState = ref.watch(getAdminFoodProvider);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Admin
          CommonUI().myText(
            text: "Welcome Admin! 👋",
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
          CommonUI().myText(
            text: "Manage your delicious Chikx menu and inventory here.",
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          Gap(4.h),

          // Add New Food Item Form Card
          _buildAddFoodCard(),
          Gap(4.h),


          // Promotions & Offers Banner
          _buildPromotionsBanner(),
          Gap(4.h),

          // Live Menu Items Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.list_alt,
                      size: 20,
                      color: AppColors.black,
                    ),
                  ),
                  Gap(3.w),
                  CommonUI().myText(
                    text: "Live Menu Items",
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 16,
                      color: Colors.black54,
                    ),
                    Gap(2.w),
                    CommonUI().myText(
                      text: "FILTER",
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(3.h),

          // List of Items
          if (getFoodState is GetFoodLoadingState)
            CommonUI().menuListShimmer()
          else if (getFoodState is GetFoodSuccessSate)
            ...getFoodState.foods.map((food) => _buildLiveItem(food))
          else if (getFoodState is GetFoodErrorState)
            Center(child: Text("Error: ${getFoodState.exception}"))
          else
            const Center(child: Text("No items found.")),

          Gap(4.h),
        ],
      ),
    );
  }

  Widget _buildAddFoodCard() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSmallIconBox(Icons.add_circle_outline),
              Gap(3.w),
              CommonUI().myText(
                text: _editingFood != null ? "Edit Food Item" : "Add New Food Item",
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
              if (_editingFood != null) ...[
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _editingFood = null;
                      _itemNameController.clear();
                      _priceController.clear();
                      _descController.clear();
                      _selectedCategory = null;
                      _imageFile = null;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.red),
                )
              ]
            ],
          ),
          Gap(3.h),
          _fieldLabel("ITEM NAME"),
          CommonUI.formField(
            editingController: _itemNameController,
            hinttext: "e.g., Crispy Drumstick",
            fillColor: AppColors.fieldFill,
            borderColor: AppColors.fieldBorder,
            borderRadius: 10,
          ),
          Gap(2.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("CATEGORY"),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: AppColors.fieldFill,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: AppColors.fieldBorder),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: AppColors.fieldBorder),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: AppColors.fieldBorder),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      hint: CommonUI().myText(text: "Select", fontSize: 14.sp, color: Colors.black38),
                      items: _addCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: CommonUI().myText(text: category, fontSize: 14.sp, fontWeight: FontWeight.w400),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) => value == null ? "Required" : null,
                    ),
                  ],
                ),
              ),
              Gap(4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("PRICE (₹)"),
                    CommonUI.formField(
                      editingController: _priceController,
                      hinttext: "9.99",
                      fillColor: AppColors.fieldFill,
                      borderColor: AppColors.fieldBorder,
                      borderRadius: 10,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(2.h),
          _fieldLabel("DESCRIPTION"),
          CommonUI.formField(
            editingController: _descController,
            hinttext: "Describe the flavors and ingredients...",
            fillColor: AppColors.fieldFill,
            borderColor: AppColors.fieldBorder,
            borderRadius: 10,
            maxline: 3,
          ),
          Gap(3.h),
          _fieldLabel("FOOD PHOTOGRAPHY"),
          InkWell(
            onTap: _showImageSourceDialog,
            child: Container(
              width: double.infinity,
              height: 20.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F0),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.fieldBorder,
                  style: BorderStyle.solid,
                ),
                image: _imageFile != null
                    ? DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                )
                    : (_editingFood?.photo != null && _editingFood!.photo!.isNotEmpty)
                    ? DecorationImage(
                  image: _getDecorationImageProvider(_editingFood!.photo!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: _imageFile == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 35,
                    color: AppColors.textBrown,
                  ),
                  Gap(1.h),
                  CommonUI().myText(
                    text: "Click to upload image",
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  CommonUI().myText(
                    text: "PNG, JPG up to 5MB",
                    fontSize: 11.sp,
                    color: Colors.black38,
                  ),
                ],
              )
                  : Stack(
                children: [
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: AppColors.textBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(3.h),
          CommonUI.buildButton(
            onPressed: () {
              String selectedImg = "";
              if (_imageFile != null) {
                List<int> imageBytes = _imageFile!.readAsBytesSync();
                selectedImg = base64Encode(imageBytes);
              } else if (_editingFood != null) {
                selectedImg = _editingFood!.photo ?? "";
              }

              var payload = AddFoodModel(
                itemName: _itemNameController.text,
                category: _selectedCategory ?? "",
                price: int.tryParse(_priceController.text) ?? 0,
                description: _descController.text,
                photo: selectedImg,
              );
              if (_editingFood != null) {
                ref.read(foodProvider.notifier).updateFoodEvent(_editingFood!.id!, payload, context);
              } else {
                ref.read(foodProvider.notifier).addFoodEvent(payload, context);
              }
            },
            width: 100.w,
            height: 5.h,
            borderradius: 12,
            gradientfirst: AppColors.primary,
            gradientsecond: AppColors.primary,
            file: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _editingFood != null ? Icons.edit : Icons.check_circle_outline,
                  color: AppColors.textBrown,
                  size: 20,
                ),
                Gap(2.w),
                CommonUI().myText(
                  text: _editingFood != null ? "UPDATE ITEM" : "SAVE NEW ITEM",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBrown,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonUI().myText(
          text: label,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
        CommonUI().myText(
          text: value,
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: valueColor,
        ),
      ],
    );
  }

  Widget _buildLiveItem(GetFoodsModel food) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildImageWidget(food.photo ?? ""),
          ),
          Gap(4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _tag(
                      food.category ?? "General",
                      const Color(0xFFFEF3C7),
                      AppColors.textBrown,
                    ),
                    Gap(2.w),
                    _tag(
                      "STOCK: 0 UNITS",
                      const Color(0xFFDCFCE7),
                      Colors.green,
                    ),
                  ],
                ),
                Gap(1.h),
                CommonUI().myText(
                  text: food.itemName ?? "Unnamed",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
                CommonUI().myText(
                  text: food.description ?? "No description",
                  fontSize: 11.sp,
                  color: Colors.black38,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CommonUI().myText(
                text: "₹${food.price ?? 0}",
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textBrown,
              ),
              Gap(1.h),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: Colors.black45,
                  ),
                  Gap(2.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _editingFood = food;
                        _itemNameController.text = food.itemName ?? "";
                        _priceController.text = food.price?.toString() ?? "";
                        _descController.text = food.description ?? "";
                        _selectedCategory = food.category;
                        _imageFile = null;
                      });
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Icon(Icons.edit_note, size: 22, color: Colors.black45),
                  ),
                  Gap(2.w),
                  GestureDetector(
                    onTap: () {
                      _showDeleteDialog(food);
                    },
                    child: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(GetFoodsModel food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Food Item"),
        content: Text("Are you sure you want to delete '${food.itemName}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (food.id != null) {
                ref.read(foodProvider.notifier).deleteFoodEvent(food.id!, context);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
      return const AssetImage('assets/placeholder.png'); // Add a placeholder asset if you have one
    }
  }

  Widget _buildImageWidget(String imageData) {
    if (imageData.isEmpty) {
      return Container(
        color: Colors.grey[200],
        width: 20.w,
        height: 20.w,
        child: const Icon(Icons.fastfood, color: Colors.grey),
      );
    }

    if (imageData.startsWith('assets/')) {
      return Image.asset(
        imageData,
        width: 20.w,
        height: 20.w,
        fit: BoxFit.cover,
      );
    }

    try {
      // Handle Base64 with or without prefix
      String base64Str = imageData;
      if (imageData.contains(',')) {
        base64Str = imageData
            .split(',')
            .last;
      }
      return Image.memory(
        base64Decode(base64Str),
        width: 20.w,
        height: 20.w,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) =>
            Container(
              color: Colors.grey[200],
              width: 20.w,
              height: 20.w,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
      );
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        width: 20.w,
        height: 20.w,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  Widget _tag(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: CommonUI().myText(
        text: text,
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: textCol,
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: CommonUI().myText(
        text: label,
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildPromotionsBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SpecialOffersScreen()),
        );
      },
      child: Container(
        width: 100.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFBBF24)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign, color: AppColors.textBrown, size: 24),
            ),
            Gap(4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonUI().myText(
                    text: "Manage Special Offers",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBrown,
                  ),
                  CommonUI().myText(
                    text: "Create deals, banners & notifications",
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBrown.withOpacity(0.8),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textBrown),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallIconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: AppColors.textBrown),
    );
  }
}
