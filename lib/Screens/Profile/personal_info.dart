import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/profile_pod.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/app_token.dart';
import 'package:chikx/Utils/appdata_helper.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  final GetProfileModel profile;

  const PersonalInfoScreen({super.key, required this.profile});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final String name = _fullNameController.text.trim();
      final String email = _emailController.text.trim();
      final String phone = _phoneController.text.trim();

      final Map<String, dynamic> payload = {};

      if (name.isNotEmpty) {
        payload['fullName'] = name;
        payload['name'] = name;
      }
      if (email.isNotEmpty) {
        payload['email'] = email;
      }
      if (phone.isNotEmpty) {
        payload['phone'] = phone;
      }

      if (payload.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter at least one field to update")),
        );
        return;
      }

      String? userId = await getUserId();
      if (userId != null) {
        ref.read(getProfileProvider.notifier).uploadProfile(userId, payload, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(getProfileProvider, (previous, next) {
      if (next is UploadProfileSuccessSate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Personal info updated successfully")),
        );
        setState(() {
          _isEditing = false;
        });
      }
    });

    final profileState = ref.watch(getProfileProvider);
    final isLoading = profileState is UploadProfileLoadingState;

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBrown),
            onPressed: () => Navigator.pop(context),
          ),
          title: CommonUI().myText(
            text: "Personal Info",
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit_outlined,
                color: AppColors.textBrown,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(5.w),
          child: _isEditing ? _buildEditForm(isLoading) : _buildReadOnlyView(),
        ),
      ),
    );
  }

  Widget _buildReadOnlyView() {
    return Column(
      children: [
        _buildInfoTile(
          "Full Name",
          _fullNameController.text.isEmpty ? "Not set" : _fullNameController.text,
          Icons.person_outline,
        ),
        _buildInfoTile(
          "Email Address",
          _emailController.text.isEmpty ? "Not set" : _emailController.text,
          Icons.email_outlined,
        ),
        _buildInfoTile(
          "Phone Number",
          _phoneController.text.isEmpty ? "Not set" : _phoneController.text,
          Icons.phone_android_outlined,
        ),
        Gap(4.h),
        CommonUI.buildButton(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          width: double.infinity,
          height: 6.h,
          borderradius: 10,
          gradientfirst: AppColors.primary,
          gradientsecond: AppColors.primary,
          file: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_outlined, color: AppColors.textBrown, size: 20),
              Gap(2.w),
              CommonUI().myText(
                text: "Edit Details",
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textBrown,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textBrown, size: 22),
          ),
          Gap(4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonUI().myText(
                  text: label,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
                CommonUI().myText(
                  text: value,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textBrown),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(bool isLoading) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Full Name"),
          CommonUI.formField(
            editingController: _fullNameController,
            hinttext: "Enter full name",
            fillColor: AppColors.white,
            borderColor: AppColors.fieldBorder,
            borderRadius: 12,
            contentsize: 14,
            icons: const Icon(
              Icons.person_outline,
              color: AppColors.textGrey,
              size: 20,
            ),
            validator: (val) {
              if (val != null && val.trim().isNotEmpty && val.trim().length < 2) {
                return "Name must be at least 2 characters";
              }
              return null;
            },
          ),
          Gap(2.5.h),

          _buildFieldLabel("Email Address"),
          CommonUI.formField(
            editingController: _emailController,
            hinttext: "you@example.com",
            fillColor: AppColors.white,
            borderColor: AppColors.fieldBorder,
            borderRadius: 12,
            contentsize: 14,
            keyboardType: TextInputType.emailAddress,
            icons: const Icon(
              Icons.email_outlined,
              color: AppColors.textGrey,
              size: 20,
            ),
            validator: (val) {
              if (val != null && val.trim().isNotEmpty && !AppDataHelper.isValidEmail(val.trim())) {
                return "Please enter a valid email address";
              }
              return null;
            },
          ),
          Gap(2.5.h),

          _buildFieldLabel("Phone Number"),
          CommonUI.formField(
            editingController: _phoneController,
            hinttext: "10-digit phone number",
            fillColor: AppColors.white,
            borderColor: AppColors.fieldBorder,
            borderRadius: 12,
            contentsize: 14,
            maxLength: 10,
            keyboardType: TextInputType.number,
            icons: const Icon(
              Icons.phone_android_outlined,
              color: AppColors.textGrey,
              size: 20,
            ),
            validator: (val) {
              if (val != null && val.trim().isNotEmpty && val.trim().length != 10) {
                return "Phone number must be 10 digits";
              }
              return null;
            },
          ),
          Gap(4.h),

          CommonUI.buildButton(
            onPressed: () {
              if (!isLoading) _saveProfile();
            },
            width: double.infinity,
            height: 6.h,
            borderradius: 10,
            gradientfirst: AppColors.primary,
            gradientsecond: AppColors.primary,
            file: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.textBrown,
                        strokeWidth: 2,
                      ),
                    )
                  : CommonUI().myText(
                      text: "Save Changes",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBrown,
                    ),
            ),
          ),
          Gap(2.h),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _fullNameController.text = widget.profile.name;
                  _emailController.text = widget.profile.email;
                  _phoneController.text = widget.profile.phone;
                });
              },
              child: CommonUI().myText(
                text: "Cancel",
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: CommonUI().myText(
        text: label,
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textBrown.withValues(alpha: 0.9),
      ),
    );
  }
}
