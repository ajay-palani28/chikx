import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'app_assets.dart';
import 'app_colors.dart';
import 'appdata_helper.dart';

class CommonUI {

  Widget myText({
    required String? text,
    double fontSize = 15,
    double letterSpacing = 0.1,
    TextAlign? textAlign = TextAlign.start,
    fontWeight = FontWeight.w500,
    color = AppColors.black,
    TextOverflow overflow = TextOverflow.ellipsis,
    int maxLines = 0,
    TextDecoration decoration = TextDecoration.none,
    double lineHeight = 0.0,
    double height = 1.5,
  }) {
    //var letterspacing = letterSpacing == 15 ? 0.3.sp : letterSpacing;
    final context = AppDataHelper.rootContext;
    if (context == null) {
      return Text(
        text!,
        overflow: overflow,
        textAlign: textAlign,
        maxLines: maxLines == 0 ? null : maxLines,
        style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            decoration: decoration,
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 1.5,
            decorationColor: color,
            textBaseline: TextBaseline.alphabetic,
            color: color,
            fontWeight: fontWeight,
            height: height,
            letterSpacing: letterSpacing),
      );
    }
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(1.0)),
      child: Text(
        text!,
        overflow: overflow,
        textAlign: textAlign,
        maxLines: maxLines == 0 ? null : maxLines,
        style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            decoration: decoration,
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 1.5,
            decorationColor: color,
            textBaseline: TextBaseline.alphabetic,
            color: color,
            shadows: [
              Shadow(
                blurRadius: 0.0,
                color: Colors.blue.shade900.withOpacity(0.0),
                offset: Offset(0.0, 0.0),
              ),
            ],
            fontWeight: fontWeight,
            height: height,
            letterSpacing: letterSpacing),
      ),
    );
  }

  Widget capitalizeText({
    required String? text,
    double fontSize = 15,
    double letterSpacing = 0.1,
    TextAlign? textAlign = TextAlign.start,
    fontWeight = FontWeight.w500,
    color = AppColors.neutral,
    TextOverflow overflow = TextOverflow.ellipsis,
    int maxLines = 0,
    TextDecoration decoration = TextDecoration.none,
    double lineHeight = 0.0,
    double height = 1.5,
  }) {
    //var letterspacing = letterSpacing == 15 ? 0.3.sp : letterSpacing;
    final context = AppDataHelper.rootContext;
    if (context == null) {
      return Text(
        '${text!.substring(0, 1).toUpperCase()}${text.substring(1)}',
        overflow: overflow,
        textAlign: textAlign,
        maxLines: maxLines == 0 ? null : maxLines,
        style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            height: height,
            letterSpacing: letterSpacing),
      );
    }
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(1.0)),
      child: Text(
        '${text!.substring(0, 1).toUpperCase()}${text.substring(1)}',
        overflow: overflow,
        textAlign: textAlign,
        maxLines: maxLines == 0 ? null : maxLines,
        style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            height: height,
            letterSpacing: letterSpacing),
      ),
    );
  }

  static Widget formField(
      {required TextEditingController editingController,
        required String hinttext,
        Key? key,
        String? prefix = "",
        bool? enabled = true,
        bool obsecuretext = false,
        bool readOnly = false,
        AutovalidateMode? autovalidateMode,
        List? inputFormatters,
        TextInputType? keyboardType,
        textInputAction,
        VoidCallback? onTap,
        String? Function(String?)? validator,
        textAlign,
        focusNode,
        int? maxLength,
        int? maxline = 1,
        onEditingComplete,
        onChanged,
        onFieldSubmitted,
        style,
        OutlineInputBorder? disabledBorder,
        Widget? icons,
        Widget? suffix,
        double contentsize = 6,
        Color prefixColor = AppColors.white,
        Color fillColor = AppColors.white,
        Color borderColor = AppColors.black,
        double borderRadius = 5.0,
        textCapitalization}) {
    final context = AppDataHelper.rootContext;
    if (context == null) {
      return TextFormField(
        enabled: enabled,
        key: key,
        readOnly: readOnly,
        autovalidateMode: autovalidateMode,
        controller: editingController,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLength: maxLength,
        obscureText: obsecuretext,
        maxLines: maxline,
        onChanged: onChanged,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
            : keyboardType == TextInputType.name
            ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))]
            : [
          FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z0-9.,@\-\s]'))
        ],
        textCapitalization: TextCapitalization.sentences,
        validator: validator,
        onTap: onTap,
        decoration: InputDecoration(
          isDense: true,
          counterText: "",
          fillColor: fillColor,
          filled: true,
          contentPadding: EdgeInsets.all(contentsize),
          hintStyle: TextStyle(color: AppColors.black.withOpacity(0.5)),
          prefix: Padding(
            padding: EdgeInsets.all(prefix != "" ? 4.0 : 4),
            child: CommonUI().myText(
                text: prefix,
                fontSize: 15.sp,
                color: AppColors.black,
                fontWeight: FontWeight.w300),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(icons != null ? 8.0 : 4),
            child: icons,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: suffix,
          ),
          suffixIconConstraints:
          BoxConstraints(maxHeight: 20.h, maxWidth: 30.w),
          prefixIconConstraints:
          BoxConstraints(maxHeight: 20.h, maxWidth: 30.w),
          prefixStyle: TextStyle(color: prefixColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hinttext,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: borderColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: borderColor),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 1),
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius),
              )),
        ),
        textAlign: TextAlign.start,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 15.sp,
            color: AppColors.black,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.1.h),
        // style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      );
    }
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(1.0)),
      child: TextFormField(
        enabled: enabled,
        key: key,
        readOnly: readOnly,
        autovalidateMode: autovalidateMode,
        controller: editingController,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLength: maxLength,
        obscureText: obsecuretext,
        maxLines: maxline,
        onChanged: onChanged,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
            : keyboardType == TextInputType.name
            ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))]
            : [
          FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z0-9.,@\-\s]'))
        ],
        textCapitalization: TextCapitalization.sentences,
        validator: validator,
        onTap: onTap,
        decoration: InputDecoration(
          isDense: true,
          counterText: "",
          fillColor: fillColor,
          filled: true,
          contentPadding: EdgeInsets.all(contentsize),
          hintStyle: TextStyle(color: AppColors.black.withOpacity(0.5)),
          prefix: Padding(
            padding: EdgeInsets.all(prefix != "" ? 4.0 : 4),
            child: CommonUI().myText(
                text: prefix,
                fontSize: 15.sp,
                color: AppColors.black,
                fontWeight: FontWeight.w300),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(icons != null ? 8.0 : 4),
            child: icons,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: suffix,
          ),
          suffixIconConstraints:
          BoxConstraints(maxHeight: 20.h, maxWidth: 30.w),
          prefixIconConstraints:
          BoxConstraints(maxHeight: 20.h, maxWidth: 30.w),
          prefixStyle: TextStyle(color: prefixColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hinttext,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: borderColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: borderColor),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 1),
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius),
              )),
        ),
        textAlign: TextAlign.start,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 15.sp,
            color: AppColors.black,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.1.h),
        // style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget buildButton({
    required VoidCallback onPressed,
    //   required String text,
    required Widget file,
    double width = 30,
    double height = 6.5,
    double fontsize = 10,
    double letterspacing = 2,
    Color bordercolor = AppColors.white,
    Color color = AppColors.white,
    double opacity = 1,
    Color gradientfirst = AppColors.primary,
    Color gradientsecond = AppColors.primary,
    double borderradius = 10.0,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [gradientfirst, gradientsecond]),
            border: Border.all(color: bordercolor),
            borderRadius: BorderRadius.circular(borderradius),
          ),
          child: file),
    );
  }

  Widget commonShimmerEffect({
    double height = 20,
    double width = double.infinity,
    double borderradius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderradius),
        ),
      ),
    );
  }

  Widget foodCardShimmer() {
    return Container(
      width: 65.w,
      margin: EdgeInsets.only(right: 4.w, bottom: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonShimmerEffect(height: 18.h, borderradius: 20),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                commonShimmerEffect(height: 2.h, width: 20.w),
                Gap(1.h),
                commonShimmerEffect(height: 2.5.h, width: 40.w),
                Gap(0.5.h),
                commonShimmerEffect(height: 2.h, width: 50.w),
                Gap(1.h), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    commonShimmerEffect(height: 3.h, width: 15.w),
                    commonShimmerEffect(height: 4.h, width: 4.h, borderradius: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> references() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Widget menuGridShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 3.h,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF3E7).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: commonShimmerEffect(borderradius: 20)),
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    commonShimmerEffect(height: 2.h, width: 25.w),
                    Gap(0.5.h),
                    commonShimmerEffect(height: 1.5.h, width: 15.w),
                    Gap(1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        commonShimmerEffect(height: 2.h, width: 10.w),
                        commonShimmerEffect(height: 3.h, width: 3.h, borderradius: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget menuListShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              commonShimmerEffect(height: 20.w, width: 20.w, borderradius: 10),
              Gap(4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        commonShimmerEffect(height: 2.h, width: 15.w, borderradius: 10),
                        Gap(2.w),
                        commonShimmerEffect(height: 2.h, width: 20.w, borderradius: 10),
                      ],
                    ),
                    Gap(1.h),
                    commonShimmerEffect(height: 2.h, width: 40.w),
                    Gap(0.5.h),
                    commonShimmerEffect(height: 1.5.h, width: 30.w),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  commonShimmerEffect(height: 2.h, width: 12.w),
                  Gap(1.h),
                  Row(
                    children: [
                      commonShimmerEffect(height: 2.5.h, width: 2.5.h, borderradius: 5),
                      Gap(2.w),
                      commonShimmerEffect(height: 2.5.h, width: 2.5.h, borderradius: 5),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget profileShimmer() {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          commonShimmerEffect(height: 100, width: 100, borderradius: 50),
          Gap(2.h),
          commonShimmerEffect(height: 3.h, width: 40.w),
          Gap(1.h),
          commonShimmerEffect(height: 2.h, width: 60.w),
          Gap(1.h),
          commonShimmerEffect(height: 2.h, width: 50.w),
          Gap(2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              commonShimmerEffect(height: 3.h, width: 25.w, borderradius: 10),
              Gap(3.w),
              commonShimmerEffect(height: 3.h, width: 20.w, borderradius: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget chatListShimmer() {
    return ListView.builder(
      itemCount: 6,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      itemBuilder: (context, index) {
        bool isMe = index % 2 == 0;
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                commonShimmerEffect(
                  height: 6.h,
                  width: 60.w,
                  borderradius: 15,
                ),
                Gap(0.5.h),
                commonShimmerEffect(height: 1.5.h, width: 15.w),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget userListShimmer() {
    return ListView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              commonShimmerEffect(height: 60, width: 60, borderradius: 30),
              Gap(4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    commonShimmerEffect(height: 2.h, width: 40.w),
                    Gap(1.h),
                    Row(
                      children: [
                        commonShimmerEffect(height: 1.5.h, width: 4.w, borderradius: 2),
                        Gap(2.w),
                        commonShimmerEffect(height: 1.5.h, width: 35.w),
                      ],
                    ),
                    Gap(0.8.h),
                    Row(
                      children: [
                        commonShimmerEffect(height: 1.5.h, width: 4.w, borderradius: 2),
                        Gap(2.w),
                        commonShimmerEffect(height: 1.5.h, width: 30.w),
                      ],
                    ),
                  ],
                ),
              ),
              commonShimmerEffect(height: 3.h, width: 3.h, borderradius: 5),
            ],
          ),
        );
      },
    );
  }

  Widget commonRequiredText({
    required String? text,
    double fontSize = 15,
    fontWeight = FontWeight.w500,
    color = AppColors.black,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return RichText(
        text: TextSpan(
            text: text,
            style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize, fontWeight: FontWeight.w400, color: color),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red))
            ]));
  }

  Widget appLogo({double? width, double? height}) {
    return Image.asset(
      AppAssets.chikx_logo,
      width: width ?? 40.w,
      height: height ?? 40.w,
    );
  }
}
