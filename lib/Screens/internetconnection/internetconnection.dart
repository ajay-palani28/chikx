import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';
import '../../RiverPod/connectivity_pod.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/commonui.dart';

class InternetConnectionScreen extends ConsumerStatefulWidget {
  const InternetConnectionScreen({super.key});

  @override
  ConsumerState<InternetConnectionScreen> createState() => _InternetConnectionScreenState();
}

class _InternetConnectionScreenState extends ConsumerState<InternetConnectionScreen> {
  bool _isChecking = false;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });

    try {
      // Manually trigger the connectivity check in the provider
      await ref.read(connectivityStatusProvider.notifier).checkConnectivity();
      
      final currentStatus = ref.read(connectivityStatusProvider);
      if (currentStatus == ConnectivityStatus.isDisconnected) {
        _showNoInternetMessage();
      }
    } catch (e) {
      _showNoInternetMessage();
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _showNoInternetMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Still no internet connection. Please try again."),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.wifi_off_rounded,
                size: 50.sp,
                color: AppColors.primary,
              ),
              Gap(4.h),
              CommonUI().myText(
                text: "No Internet Connection",
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.center,
              ),
              Gap(2.h),
              CommonUI().myText(
                text: "Please check your internet connection and try again to continue using the app.",
                fontSize: 15.sp,
                color: Colors.black54,
                textAlign: TextAlign.center,
                maxLines: 4,
              ),
              const Spacer(),
              _isChecking
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : CommonUI.buildButton(
                      onPressed: _checkConnection,
                      width: double.infinity,
                      height: 6.5.h,
                      borderradius: 15,
                      gradientfirst: AppColors.primary,
                      gradientsecond: AppColors.primary,
                      file: Center(
                        child: CommonUI().myText(
                          text: "Try Again",
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textBrown,
                        ),
                      ),
                    ),
              Gap(5.h),
            ],
          ),
        ),
      ),
    );
  }
}
