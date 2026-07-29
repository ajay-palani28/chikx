import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

import 'app_colors.dart';
import 'appdata_helper.dart';
import 'commonui.dart';

class AppAlertController {
  var _isLoaderShowing = false;
  static final AppAlertController _inst = AppAlertController._internal();

  AppAlertController._internal();

  factory AppAlertController() => _inst;
  BuildContext? _indicatorContext = AppDataHelper.rootContext;

  Future<void> showProgressIndicator({BuildContext? inContext}) async {
    if (_isLoaderShowing) return;
    _isLoaderShowing = true;

    _indicatorContext = inContext ?? AppDataHelper.rootContext;
    return showGeneralDialog<void>(
        barrierDismissible: false,
        transitionDuration: Duration(milliseconds: 300),
        barrierColor: Colors.black54,
        context: inContext ?? AppDataHelper.rootContext!,
        pageBuilder: (context, animation, secondaryAnimation) {
          return loaderWidget(inContext: _indicatorContext!);
        },
        transitionBuilder: _transitionBuilder);
  }

  Widget loaderWidget({BuildContext? inContext}) {
    double loaderSize =
        MediaQuery.of(inContext ?? AppDataHelper.rootContext!).size.width * 0.1;
    var loader = PopScope(
      canPop: false,
      child: SizedBox(
        width: loaderSize,
        height: loaderSize,
        child: CircularProgressIndicator(
          backgroundColor: AppColors.primary,
          color: Colors.grey,
        ),
      ),
    );
    var loadWithBG = Container(
      width: loaderSize * 2,
      height: loaderSize * 2,
      child: Center(
        child: loader,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(20))),
    );
    return Container(
      child: Center(
        child: loadWithBG,
      ),
    );
  }

  Widget _transitionBuilder(context, animation, secondaryAnimation, child) =>
      Transform.scale(
        scale: animation.value,
        child: Opacity(
          opacity: animation.value,
          child: child,
        ),
      );

  void hideProgressIndicator() {
    if (!_isLoaderShowing) return;
    Navigator.pop(_indicatorContext!);
    _isLoaderShowing = false;
  }

  void showAlert({
    String title = 'CHIKX',
    required String message,
    String? cancelTitle,
    String? otherTitle,
    bool isOkButtonShown=true,
    VoidCallback? otherAction,
    VoidCallback? cancelAction,
    required BuildContext? inContext,
  }) async {
    int tabControl=0;
    hideProgressIndicator();

    final BuildContext context =
        inContext ?? AppDataHelper.rootContext!;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.bgColor.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            elevation: 0.2,
            color: AppColors.white,

            borderRadius: BorderRadius.circular(5),
            child: Container(
              width: 90.w,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CommonUI().myText(
                        text: title,
                        fontSize: 15.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  Divider(color: AppColors.primaryLight, thickness: 0.1,),
                  Gap(2.h),
                  SizedBox(
                    // height: 3.h,
                    // height: 12.h,
                    child: SingleChildScrollView(
                      child: Center(
                        child: CommonUI().myText(
                          text: message.startsWith('Exception:')
                              ? message.split('Exception:')[1]
                              : message,
                          textAlign: TextAlign.center,
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ),

                  Gap(2.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CommonUI.buildButton(
                        width: 18.w,
                        height: 4.h,
                        borderradius: 5,
                        // color: AppColors.white,
                        gradientfirst: AppColors.primary,
                        gradientsecond: AppColors.primary,
                        bordercolor: AppColors.white,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          if (cancelAction != null) {
                            cancelAction();
                          }
                        },
                        file: Center(
                          child: CommonUI().myText(
                            text: cancelTitle ?? 'Ok',
                            color: AppColors.white,
                          ),
                        ),
                      ),

                      if (otherTitle != null) ...[
                        Gap(2.w),

                        CommonUI.buildButton(
                          width: 18.w,
                          height: 4.h,
                          borderradius: 5,
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            if (otherAction != null) {
                              otherAction();
                            }
                          },
                          file: Center(
                            child: CommonUI().myText(
                              text: otherTitle,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Gap(1.5.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}