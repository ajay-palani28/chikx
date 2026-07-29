import 'package:chikx/Models/app_model.dart';
import 'package:chikx/RiverPod/create_account_pod.dart';
import 'package:chikx/Screens/Login/login.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

import '../../Provider/providers.dart';
import '../../Utils/appdata_helper.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _securityAnswer1Controller = TextEditingController();
  final TextEditingController _securityAnswer2Controller = TextEditingController();

  String? _selectedQuestion1;
  String? _selectedQuestion2;

  final List<String> _questions1 = [
    "What was your childhood nickname?",
    "What is the name of your favorite childhood friend?",
    "In what city or town did your mother and father meet?",
    "What is your favorite book?",
  ];

  final List<String> _questions2 = [
    "What was the name of your first stuffed animal?",
    "What was the name of your elementary school?",
    "What is the name of the company where you had your first job?",
    "What was the model of your first car?",
  ];

  String? selectedDob;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
        "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  void _validateAndSubmit(WidgetRef ref) {
    if (_formKey.currentState!.validate()) {
      if (_selectedQuestion1 == null || _selectedQuestion2 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select security questions")),
        );
        return;
      }
      var payload = CreateAccountModel(
        fullName: _fullNameController.text.trim(),
        dob: _dobController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        cpassword: _confirmPasswordController.text,
        securityQuestion1: _selectedQuestion1!,
        securityAnswer1: _securityAnswer1Controller.text.trim(),
        securityQuestion2: _selectedQuestion2!,
        securityAnswer2: _securityAnswer2Controller.text.trim(),
      );
      print('Payload: ${payload.toJson()}');
      ref.read(createAccountProvider.notifier).createAccount(payload, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen(createAccountProvider, (previous, next) {
            if (next is CreateAccountSuccessSate) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
              );
            }
          },);
          return Scaffold(
              backgroundColor: AppColors.bgColor,
              body: SafeArea(
                child: Column(
                    children: [
                // Custom Header
                Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textBrown,
                      ),
                    ),
                    CommonUI().myText(
                      text: "CHIKX",
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                    ),
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.fieldBorder),
                        image: const DecorationImage(
                          image: AssetImage('assets/chikx_logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.fieldBorder),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonUI().myText(
                          text: "Create Account",
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                        Gap(1.h),
                        CommonUI().myText(
                          text:
                          "Fill in your details to start your CHIKX journey. 🍗FRESHU, 😋TASTEE, ✨ QUALITE",
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black.withOpacity(0.7),
                          maxLines: 0,
                          overflow: TextOverflow.visible,
                        ),
                        Gap(3.h),

                        _buildFieldLabel("Full Name"),
                        CommonUI.formField(
                          editingController: _fullNameController,
                          hinttext: "Enter your full name",
                          fillColor: Colors.white,
                          borderColor: AppColors.fieldBorder,
                          borderRadius: 10,
                          icons: Icon(
                            Icons.person_outline,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          contentsize: 14,
                          validator: (val) {
                            if (val == null || val
                                .trim()
                                .isEmpty) {
                              return "Full Name is required";
                            }
                            return null;
                          },
                        ),
                        Gap(2.h),

                        _buildFieldLabel("Date of Birth"),
                        CommonUI.formField(
                          editingController: _dobController,
                          hinttext: "dd/mm/yyyy",
                          fillColor: Colors.white,
                          borderColor: AppColors.fieldBorder,
                          borderRadius: 10,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          icons: Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          suffix: Icon(
                            Icons.calendar_today,
                            color: AppColors.black,
                            size: 18,
                          ),
                          contentsize: 14,
                          validator: (val) {
                            if (val == null || val
                                .trim()
                                .isEmpty) {
                              return "Date of Birth is required";
                            }
                            return null;
                          },
                        ),
                        Gap(2.h),

                        _buildFieldLabel("Phone Number"),
                        CommonUI.formField(
                          editingController: _phoneController,
                          hinttext: "+91 1234567890",
                          fillColor: Colors.white,
                          borderColor: AppColors.fieldBorder,
                          borderRadius: 10,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          icons: Icon(
                            Icons.phone_outlined,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          contentsize: 14,
                          validator: (val) {
                            if (val == null || val
                                .trim()
                                .isEmpty) {
                              return "Phone Number is required";
                            }
                            if (val
                                .trim()
                                .length != 10) {
                              return "Phone Number must be 10 digits";
                            }
                            return null;
                          },
                        ),
                        Gap(2.h),

                        _buildFieldLabel("Email Address"),
                        CommonUI.formField(
                          editingController: _emailController,
                          hinttext: "you@example.com",
                          fillColor: Colors.white,
                          borderColor: AppColors.fieldBorder,
                          borderRadius: 10,
                          keyboardType: TextInputType.emailAddress,
                          icons: Icon(
                            Icons.email_outlined,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          contentsize: 14,
                          validator: (val) {
                            if (val != null && val
                                .trim()
                                .isNotEmpty && !AppDataHelper.isValidEmail(
                                val.trim())) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                        ),
                        Gap(2.h),

                        _buildFieldLabel("Password"),
                        CommonUI.formField(
                          editingController: _passwordController,
                          hinttext: "••••••••",
                          fillColor: Colors.white,
                          borderColor: AppColors.fieldBorder,
                          borderRadius: 10,
                          obsecuretext: true,
                          icons: Icon(
                            Icons.lock_outline,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          contentsize: 14,
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

                        _buildFieldLabel("Confirm Password"),
                        CommonUI.formField(
                          editingController: _confirmPasswordController,
                          hinttext: "••••••••",
                          fillColor: Colors.white,
                          borderColor: AppColors.fieldBorder,
                          borderRadius: 10,
                          obsecuretext: true,
                          icons: Icon(
                            Icons.lock_reset,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          contentsize: 14,
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
                        Gap(2.h),

                        _buildFieldLabel("Security Question 1"),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.fieldBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: CommonUI().myText(text: "Select Question 1", fontSize: 14.sp, color: AppColors.textGrey),
                              value: _selectedQuestion1,
                              items: _questions1.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedQuestion1 = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        Gap(1.h),
                        CommonUI.formField(
                          editingController: _securityAnswer1Controller,
                          hinttext: "Enter Answer 1",
                          fillColor: Colors.white,
                          borderColor: AppColors.fieldBorder,
                          borderRadius: 10,
                          icons: Icon(
                            Icons.question_answer_outlined,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          contentsize: 14,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Answer 1 is required";
                            }
                            return null;
                          },
                        ),
                        Gap(2.h),

                        _buildFieldLabel("Security Question 2"),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.fieldBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: CommonUI().myText(text: "Select Question 2", fontSize: 14.sp, color: AppColors.textGrey),
                              value: _selectedQuestion2,
                              items: _questions2.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedQuestion2 = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        Gap(1.h),
                        CommonUI.formField(
                          editingController: _securityAnswer2Controller,
                          hinttext: "Enter Answer 2",
                          fillColor: Colors.white,
                          borderColor: AppColors.fieldBorder,
                          borderRadius: 10,
                          icons: Icon(
                            Icons.question_answer_outlined,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          contentsize: 14,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Answer 2 is required";
                            }
                            return null;
                          },
                        ),
                        Gap(4.h),

                        // Create Account Button
                        Consumer(
                            builder: (context, ref, child) {
                              return CommonUI.buildButton(
                                onPressed: () => _validateAndSubmit(ref),
                                width: 100.w,
                                height: 5.h,
                                borderradius: 10,
                                gradientfirst: AppColors.primary,
                                gradientsecond: AppColors.primary,
                                file: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CommonUI().myText(
                                      text: "Create Account",
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textBrown,
                                    ),
                                    Gap(2.w),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.textBrown,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              );
                            }
                        ),
                        Gap(3.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CommonUI().myText(
                              text: "Already have an account? ",
                              color: Colors.black54,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            Gap(2.w),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()),
                                );
                              },
                              child: CommonUI().myText(
                                text: "Log In",
                                color: AppColors.textBrown,
                                fontWeight: FontWeight.w800,
                                fontSize: 15.sp,
                              ),
                            ),
                          ],
                        ),
                        Gap(3.h),
                      ],
                    ),
                  ),
                ),
              )]
          ),));
        }
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: CommonUI().myText(
        text: label,
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textBrown.withOpacity(0.9),
      ),
    );
  }

  Widget _buildSocialIcon(String asset) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Image.asset(
        asset,
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.g_mobiledata, size: 24, color: AppColors.textBrown),
      ),
    );
  }
}
