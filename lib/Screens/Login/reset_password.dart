import 'package:chikx/RiverPod/forgot_password_pod.dart';
import 'package:chikx/Screens/Login/login.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';
import '../../Provider/providers.dart';
import '../../Utils/app_assets.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String question1;
  final String question2;
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.question1,
    required this.question2,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _answer1Controller = TextEditingController();
  final TextEditingController _answer2Controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      ref.read(forgotPasswordProvider.notifier).verifyAnswersAndReset(
        email: widget.email,
        answer1: _answer1Controller.text.trim(),
        answer2: _answer2Controller.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(forgotPasswordProvider, (previous, next) {
      if (next is ForgotPasswordSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      }
    });

    final state = ref.watch(forgotPasswordProvider);

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
                  text: "Reset Password",
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                Gap(2.h),
                CommonUI().myText(
                  text: "Answer your security questions to reset your password.",
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
                    text: widget.question1,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black.withOpacity(0.7),
                    maxLines: 0,
                  ),
                ),
                Gap(1.h),
                CommonUI.formField(
                  editingController: _answer1Controller,
                  hinttext: "Enter Answer 1",
                  fillColor: Colors.white,
                  borderColor: AppColors.fieldBorder,
                  borderRadius: 12,
                  contentsize: 18,
                  icons: const Icon(Icons.question_answer_outlined, color: Colors.black45),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Answer 1 is required";
                    }
                    return null;
                  },
                ),
                Gap(2.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: CommonUI().myText(
                    text: widget.question2,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black.withOpacity(0.7),
                    maxLines: 0,
                  ),
                ),
                Gap(1.h),
                CommonUI.formField(
                  editingController: _answer2Controller,
                  hinttext: "Enter Answer 2",
                  fillColor: Colors.white,
                  borderColor: AppColors.fieldBorder,
                  borderRadius: 12,
                  contentsize: 18,
                  icons: const Icon(Icons.question_answer_outlined, color: Colors.black45),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Answer 2 is required";
                    }
                    return null;
                  },
                ),
                Gap(2.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: CommonUI().myText(
                    text: "NEW PASSWORD",
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black.withOpacity(0.7),
                  ),
                ),
                Gap(1.h),
                CommonUI.formField(
                  editingController: _passwordController,
                  hinttext: "••••••••",
                  fillColor: Colors.white,
                  borderColor: AppColors.fieldBorder,
                  borderRadius: 12,
                  obsecuretext: _obscurePassword,
                  contentsize: 18,
                  icons: const Icon(Icons.lock_outline, color: Colors.black45),
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black45,
                      size: 20,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Password is required";
                    }
                    if (val.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                Gap(2.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: CommonUI().myText(
                    text: "CONFIRM NEW PASSWORD",
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black.withOpacity(0.7),
                  ),
                ),
                Gap(1.h),
                CommonUI.formField(
                  editingController: _confirmPasswordController,
                  hinttext: "••••••••",
                  fillColor: Colors.white,
                  borderColor: AppColors.fieldBorder,
                  borderRadius: 12,
                  obsecuretext: _obscureConfirmPassword,
                  contentsize: 18,
                  icons: const Icon(Icons.lock_reset, color: Colors.black45),
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    child: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black45,
                      size: 20,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (val != _passwordController.text) {
                      return "Passwords do not match";
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
                    child: (state is ForgotPasswordLoadingState)
                        ? const CircularProgressIndicator(color: AppColors.textBrown)
                        : CommonUI().myText(
                            text: "Reset Password",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textBrown,
                          ),
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
