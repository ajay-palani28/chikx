import 'package:chikx/Screens/Admin/adminDashboard.dart';
import 'package:chikx/Screens/Dashboard/dashboard.dart';
import 'package:chikx/Screens/Login/login.dart';
import 'package:chikx/Utils/app_assets.dart';
import 'package:chikx/Utils/app_colors.dart';
import 'package:chikx/Utils/commonui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Animation states for interactive feel
  double _horizontalOffset = 0.0;
  double _scale = 1.2;
  String? token;
  bool isAdmin=false;

  final TextEditingController _searchController = TextEditingController();


  getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    isAdmin=prefs.getBool('isAdmin')!;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              // Dragging left/right to pan around the hotel image
              _horizontalOffset -= details.delta.dx / 1000;
              _horizontalOffset = _horizontalOffset.clamp(-1.0, 1.0);

              // Dragging up/down to simulate entering/zooming into the hotel
              _scale -= details.delta.dy / 1000;
              _scale = _scale.clamp(1.0, 2.5);
            });
          },
          child: Stack(
            children: [
              // Background Hotel Image with Interactive Animation
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  alignment: Alignment(_horizontalOffset, 0),
                  child: Transform.scale(
                    scale: _scale,
                    child: Image.asset(
                      filterQuality: FilterQuality.low,
                      AppAssets.hotel,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),

              // Gradient Overlay for better readability of text and UI elements
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
              // Content Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),
                      // Logo centered with tagline
                      // Bottom Button
                      CommonUI.buildButton(
                        onPressed: () {
                          print('IsAdmin: ${isAdmin}');
                          if (token != null) {
                            if(isAdmin==true){
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Admindashboard()));
                            }
                            else{
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Dashboard()),
                              );
                            }
                          } else {
                            // Navigation or start action
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Login()),
                            );
                          }
                        },
                        width: 70.w,
                        height: 6.h,
                        borderradius: 30,
                        gradientfirst: AppColors.primary,
                        gradientsecond: AppColors.primary,
                        file: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CommonUI().myText(
                                text: "GET STARTED",
                                fontSize: 15.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                              Gap(2.w),
                              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      Gap(2.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
