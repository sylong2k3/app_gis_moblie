// shared/constants/app_dimensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDimensions {
  static const Size designSizeTablet = Size(1366, 1024);
  static const Size designSizeMobile = Size(393, 865);

  static Size get designSize {
    // This will be determined at runtime in main.dart
    return designSizeMobile; // Default to mobile
  }

  static Size getDesignSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    return isTablet ? designSizeTablet : designSizeMobile;
  }

  // Padding & Margin Values
  static final double paddingMicro = 4.w;
  static final double paddingSmall = 8.w;
  static final double paddingMedium = 16.w;
  static final double paddingLarge = 24.w;
  static final double paddingExtraLarge = 32.w;
  static final double paddingTopRightSide = 30.h;

  static final EdgeInsets edgeInsetsMicro = EdgeInsets.all(paddingMicro);
  static final EdgeInsets edgeInsetsSmall = EdgeInsets.all(paddingSmall);
  static final EdgeInsets edgeInsetsMedium = EdgeInsets.all(paddingMedium);
  static final EdgeInsets edgeInsetsLarge = EdgeInsets.all(paddingLarge);
  static final EdgeInsets edgePaddingBottomSheet = EdgeInsets.only(
    top: 12,
    left: 33,
    right: 33,
    bottom: 44,
  );
  static final EdgeInsets edgePaddingListView = EdgeInsets.only(
    top: 10.h,
    left: 11.5.w,
    right: 11.5.w,
    bottom: 10.h,
  );
  static final EdgeInsets edgePaddingListViewTablet = EdgeInsets.only(
    top: 10.h,
    left: 11.5.w,
    right: 11.5.w,
  );
  static final EdgeInsets linePaddingListViewTablet = EdgeInsets.only(
    left: 11.5.w,
    right: 11.5.w,
  );

  static final EdgeInsets edgeInsetsExtraLarge = EdgeInsets.all(
    paddingExtraLarge,
  );

  static EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: paddingMedium,
    vertical: paddingLarge,
  );

  // Gaps & Spacing
  static final double gapMicro = 4.h;
  static final double gapSmall = 8.h;
  static final double gapMedium = 16.h;
  static final double gapLarge = 24.h;
  static final double gapExtraLarge = 32.h;
  static final double gapItemListView = 10.h;

  // Spacing aliases for backward compatibility
  static final double spacingMicro = gapMicro;
  static final double spacingSmall = gapSmall;
  static final double spacingMedium = gapMedium;
  static final double spacingLarge = gapLarge;
  static final double spacingExtraLarge = gapExtraLarge;

  static final Widget verticalSpaceMicro = SizedBox(height: gapMicro);
  static final Widget verticalSpaceSmall = SizedBox(height: gapSmall);
  static final Widget verticalSpaceMedium = SizedBox(height: gapMedium);
  static final Widget verticalSpaceLarge = SizedBox(height: gapLarge);
  static final Widget verticalSpaceExtraLarge = SizedBox(height: gapExtraLarge);

  static final Widget horizontalSpaceMicro = SizedBox(width: gapMicro);
  static final Widget horizontalSpaceSmall = SizedBox(width: gapSmall);
  static final Widget horizontalSpaceMedium = SizedBox(width: gapMedium);
  static final Widget horizontalSpaceLarge = SizedBox(width: gapLarge);
  static final Widget horizontalSpaceExtraLarge = SizedBox(
    width: gapExtraLarge,
  );

  // Border Radius
  static final double radiusSmall = 4.r;
  static final double radiusMedium = 8.r;
  static final double radiusLarge = 12.r;
  static final double radiusExtraLarge = 16.r;
  static final double radiusCircular = 100.r; // For circular elements

  static final BorderRadius borderRadiusSmall = BorderRadius.circular(
    radiusSmall,
  );
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(
    radiusMedium,
  );
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(
    radiusLarge,
  );
  static final BorderRadius borderRadiusExtraLarge = BorderRadius.circular(
    radiusExtraLarge,
  );
  static final BorderRadius borderRadiusCircular = BorderRadius.circular(
    radiusCircular,
  );

  // Icon Sizes
  static final double iconSizeExtraSmall = 16.sp;
  static final double iconSizeSmall = 20.sp;
  static final double iconSizeMedium = 24.sp;
  static final double iconSizeLarge = 32.sp;
  static final double iconSizeExtraLarge = 40.sp;

  // Image Sizes
  static final Size imageSizeTiny = Size(20.w, 20.h);
  static final Size imageSizeExtraSmall = Size(24.w, 24.h);
  static final Size imageSizeSmall = Size(50.w, 50.h);
  static final Size imageSizeMedium = Size(100.w, 100.h);
  static final Size imageSizeLarge = Size(150.w, 150.h);
  static final Size imageSizeExtraLarge = Size(200.w, 200.h);

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Button dimensions
  static final double buttonHeight = 48.h;
  static final double buttonMinWidth = 88.w;
  static final EdgeInsets buttonBottomTabletPadding = EdgeInsets.symmetric(
    horizontal: 28.w,
    vertical: 16.w,
  );
  static final EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 8.w);

  // Input field dimensions
  static final double inputFieldHeight = 50.h;
  static final EdgeInsets inputFieldContentPadding = EdgeInsets.symmetric(
    horizontal: paddingMedium,
    vertical: paddingSmall,
  );

  static double get verticalPaddingSmall => 8.h;
  static double get inputContentPaddingVertical => 14.h;
  static double get inputContentPaddingHorizontal => 12.w;
  static double get borderWidth => 1.0.w;
  static double get focusedBorderWidth => 2.w;
}
