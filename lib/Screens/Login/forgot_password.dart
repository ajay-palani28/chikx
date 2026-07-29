import 'package:chikx/RiverPod/forgot_password_pod.dart';
import 'package:chikx/Screens/Login/reset_password.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:chikx/Utils/appdata_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';
import '../../Provider/providers.dart';
import '../../Utils/app_assets.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ConsumerState<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      ref.read(forgotPasswordProvider.notifier).fetchSecurityQuestions(_emailController.text.trim(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(forgotPasswordProvider, (previous, next) {
      if (next is ForgotPasswordQuestionsFetchedState) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: _emailController.text.trim(),
              question1: next.question1,
              question2: next.question2,
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Gap(2.h),
                Image.asset(
                  AppAssets.chikx_logo,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                Gap(8.h),

                CommonUI().myText(
                  text: "Forgot Password?",
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                Gap(2.h),
                CommonUI().myText(
                  text: "Enter your email address and we'll show your security questions to reset your password.",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  textAlign: TextAlign.center,
                  maxLines: 0,
                ),
                Gap(5.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: CommonUI().myText(
                    text: "EMAIL ADDRESS",
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black.withOpacity(0.7),
                  ),
                ),
                Gap(1.h),
                CommonUI.formField(
                  editingController: _emailController,
                  hinttext: "Enter your email",
                  fillColor: Colors.white,
                  borderColor: AppColors.fieldBorder,
                  borderRadius: 12,
                  contentsize: 18,
                  keyboardType: TextInputType.emailAddress,
                  icons: const Icon(Icons.email_outlined, color: Colors.black45),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Email is required";
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
                Gap(4.h),

                CommonUI.buildButton(
                  onPressed: _validateAndSubmit,
                  width: 100.w,
                  height: 6.h,
                  borderradius: 12,
                  gradientfirst: AppColors.primary,
                  gradientsecond: AppColors.primary,
                  file: Center(
                    child: (ref.watch(forgotPasswordProvider) is ForgotPasswordLoadingState)
                        ? const CircularProgressIndicator(color: AppColors.textBrown)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CommonUI().myText(
                                text: "Get Security Questions",
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textBrown,
                              ),
                              Gap(2.w),
                              const Icon(Icons.arrow_forward, color: AppColors.textBrown, size: 20),
                            ],
                          ),
                  ),
                ),
                Gap(5.h),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.black45, size: 18),
                      Gap(2.w),
                      CommonUI().myText(
                        text: "Back to Log In",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
