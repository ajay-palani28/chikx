import 'package:chikx/Models/app_model.dart';
import 'package:chikx/Provider/providers.dart';
import 'package:chikx/RiverPod/login_pod.dart';
import 'package:chikx/Screens/Admin/adminDashboard.dart';
import 'package:chikx/Screens/Dashboard/dashboard.dart';
import 'package:chikx/Screens/Login/create_account.dart';
import 'package:chikx/Screens/Login/forgot_password.dart';
import 'package:chikx/Utils/app_assets.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/app_token.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  void _loadRememberedCredentials() async {
    bool remember = await getRememberMe();
    if (remember) {
      String? phone = await getRememberedPhone();
      String? password = await getRememberedPassword();
      setState(() {
        _rememberMe = true;
        if (phone != null) _emailController.text = phone;
        if (password != null) _passwordController.text = password;
      });
    }
  }

  final Color brownTextColor = const Color(0xFF745223);
  final Color fieldBorderColor = const Color(0xFFE2D6C5);

  void _validateAndSubmit(WidgetRef ref) {
    if (_formKey.currentState!.validate()) {
      if (_rememberMe) {
        setRememberMe(true);
        setRememberedPhone(_emailController.text.trim());
        setRememberedPassword(_passwordController.text);
      } else {
        clearRememberedCredentials();
      }
      var payload = LoginModel(
        phone: _emailController.text.trim(),
        password: _passwordController.text,
      );
      ref.read(loginProvider.notifier).loginUser(payload, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(loginProvider, (previous, next) {
      print('Next: ${next}');
      if (next is LoginSuccessSate) {
        final loginData = next.response.data;
        if (loginData != null && loginData.token != null) {
          setToken(loginData.token!);
          setUserId(loginData.id ?? '');
          bool isAdmin = loginData.admin ?? false;
          setIsAdmin(isAdmin);
          print('Responsed login: ${loginData}');
          if (isAdmin) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Admindashboard()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          }
        }
      }
    });
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor, // Exact cream background from image
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Gap(4.h),
                // Header: Logo and Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.chikx_logo,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        Gap(2.w),
                        CommonUI().myText(
                          text: "ChikX",
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateAccount()),
                        );
                      },
                      child: CommonUI().myText(
                        text: "Sign Up",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: brownTextColor,
                      ),
                    ),
                  ],
                ),
                Gap(5.h),

                // Welcome Text
                CommonUI().myText(
                  text: "Welcome Back!",
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
                Gap(1.h),
                CommonUI().myText(
                  text: "Login to satisfy your cravings.",
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
                Gap(3.h),

                // Form Fields
                CommonUI.formField(
                  editingController: _emailController,
                  hinttext: "Phone Number",
                  fillColor: Colors.white,
                  borderColor: fieldBorderColor,
                  borderRadius: 12,
                  contentsize: 18,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Phone Number is required";
                    }
                    if (val.trim().length != 10) {
                      return "Phone Number must be 10 digits";
                    }
                    return null;
                  },
                ),
                Gap(2.h),
                CommonUI.formField(
                  editingController: _passwordController,
                  hinttext: "Password",
                  fillColor: Colors.white,
                  borderColor: fieldBorderColor,
                  borderRadius: 12,
                  obsecuretext: _obscurePassword,
                  contentsize: 18,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Password is required";
                    }
                    if (val.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                Gap(3.h),

                // Remember me and Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 3.h,
                          height: 3.h,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val!;
                              });
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: BorderSide(color: fieldBorderColor, width: 2),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Gap(2.w),
                        CommonUI().myText(
                          text: "Remember me",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black.withOpacity(0.7),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPassword()),
                        );
                      },
                      child: CommonUI().myText(
                        text: "Forgot Password?",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: brownTextColor,
                      ),
                    ),
                  ],
                ),
                Gap(4.h),

                // Order Now Button (Login)
                CommonUI.buildButton(
                  onPressed: () => _validateAndSubmit(ref),
                  width: 100.w,
                  height: 5.h,
                  borderradius: 10,
                  gradientfirst: AppColors.primary,
                  gradientsecond: AppColors.primary,
                  file: Center(
                    child: CommonUI().myText(
                      text: "Login",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: brownTextColor,
                    ),
                  ),
                ),
                Gap(2.h),

                // Google Sign In Button
                OutlinedButton(
                  onPressed: () {
                    ref.read(loginProvider.notifier).loginWithGoogle(context);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(100.w, 5.h),
                    side: const BorderSide(color: AppColors.fieldBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.g_mobiledata,
                        size: 28,
                        color: AppColors.primary,
                      ),
                      Gap(2.w),
                      CommonUI().myText(
                        text: "Continue with Google",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ],
                  ),
                ),
                Gap(3.h),

                // Create Account Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonUI().myText(text: "Don't have an account? ", color: Colors.black54,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,),
                    Gap(2.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateAccount()),
                        );
                      },
                      child: CommonUI().myText(text: "Create Account",color: brownTextColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,),
                    )
                  ],),
                Gap(6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonUI().myText(text: "Support", fontSize: 14.sp, color: Colors.black45, fontWeight: FontWeight.w600),
                    Gap(6.w),
                    CommonUI().myText(text: "Locations", fontSize: 14.sp, color: Colors.black45, fontWeight: FontWeight.w600),
                    Gap(6.w),
                    CommonUI().myText(text: "Menu", fontSize: 14.sp, color: Colors.black45, fontWeight: FontWeight.w600),
                  ],
                ),
                Gap(4.h),
              ],
            ),
          ),
        ),
      )));
  }
}
