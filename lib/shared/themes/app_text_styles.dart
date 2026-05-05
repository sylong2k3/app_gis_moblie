import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  static const String _fontFamilyInter =
      'Inter'; // Make sure Inter font is set up in pubspec.yaml and assets

  // TextHeader
  // Name: Body large/Semibold UPPERCASE
  // Font: Inter, Weight: 600 (Semibold), Size: 18.sp (responsive)
  static TextStyle get textHeader => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w600,
    fontSize: 18.sp,
  );

  // TextTitle
  // Font: Inter, Weight: 600 (Semibold), Size: 16.sp (responsive)
  static TextStyle get textTitle => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
  );

  // TextTab
  // font-family: Inter; font-weight: 500; font-size: 14.sp (responsive);
  static TextStyle get textTab => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14.sp,
  );

  // TextLabel
  // font-family: Inter; font-weight: 500; font-size: 14.sp (responsive);
  static TextStyle get textLabel => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w500,
    fontSize: 14.sp,
  );

  // TextLabelTab
  // font-family: Inter; font-weight: 500; font-size: 14.sp (responsive);
  static TextStyle get textLabelTab => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w500,
    fontSize: 14.sp,
  );

  // Example general body style
  static TextStyle get bodyRegular => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w400,
    fontSize: 16.sp,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
  );

  static TextStyle get captionLargeMedium => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14.sp,
  );

  static TextStyle get captionLargeRegular => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w400, // Medium
    fontSize: 14.sp,
  );

  static TextStyle get textButtonMobileStyle => TextStyle(
    fontFamily: _fontFamilyInter,
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
  );
  // Add more base styles as needed
}
