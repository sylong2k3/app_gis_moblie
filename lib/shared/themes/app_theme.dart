import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import './app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.black,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.secondaryDark,
      error: AppColors.error, // General error
      onError: AppColors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.errorDark,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textLightPrimary,
      onSurfaceVariant: AppColors.textLightSecondary,
      outline: AppColors.lightBorder,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      radioTheme: _buildRadioTheme(colorScheme),
      textTheme: _buildTextTheme(
        base.textTheme,
        AppColors.textLightPrimary,
        AppColors.textLightSecondary,
      ),
      appBarTheme: _buildAppBarTheme(colorScheme, Brightness.light),
      cardTheme: _buildCardTheme(colorScheme, Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(
        colorScheme,
        Brightness.light,
      ),
      textButtonTheme: _buildTextButtonTheme(colorScheme, Brightness.light),
      outlinedButtonTheme: _buildOutlinedButtonTheme(
        colorScheme,
        Brightness.light,
      ),
      inputDecorationTheme: _buildInputDecorationTheme(
        colorScheme,
        Brightness.light,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.lightBorder,
        space: 1.h,
        thickness: 1.h,
      ),
      chipTheme: _buildChipTheme(colorScheme, Brightness.light),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(
        colorScheme,
        Brightness.light,
      ),
      tabBarTheme: _buildTabBarTheme(colorScheme),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primaryLight, // Primary is often lighter in dark theme
      onPrimary: AppColors.black,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.black,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.secondaryLight,
      error: AppColors.errorLight,
      onError: AppColors.black,
      errorContainer: AppColors.errorDark,
      onErrorContainer: AppColors.errorLight,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textDarkPrimary,
      onSurfaceVariant: AppColors.textDarkSecondary,
      outline: AppColors.darkBorder,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(
        base.textTheme,
        AppColors.textDarkPrimary,
        AppColors.textDarkSecondary,
      ),
      appBarTheme: _buildAppBarTheme(colorScheme, Brightness.dark),
      cardTheme: _buildCardTheme(colorScheme, Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(
        colorScheme,
        Brightness.dark,
      ),
      textButtonTheme: _buildTextButtonTheme(colorScheme, Brightness.dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(
        colorScheme,
        Brightness.dark,
      ),
      inputDecorationTheme: _buildInputDecorationTheme(
        colorScheme,
        Brightness.dark,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder,
        space: 1.h,
        thickness: 1.h,
      ),
      chipTheme: _buildChipTheme(colorScheme, Brightness.dark),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(
        colorScheme,
        Brightness.dark,
      ),
      tabBarTheme: _buildTabBarTheme(colorScheme),
    );
  }

  static TextTheme _buildTextTheme(
    TextTheme base,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    // Apply default font family and colors to our custom base styles
    final TextStyle headerWithColor = AppTextStyles.textHeader.copyWith(
      color: primaryTextColor,
    );
    final TextStyle titleWithColor = AppTextStyles.textTitle.copyWith(
      color: primaryTextColor,
    );
    final TextStyle labelWithColor = AppTextStyles.textLabel.copyWith(
      color: primaryTextColor,
    );
    final TextStyle tabWithColor = AppTextStyles.textTab.copyWith(
      color: primaryTextColor,
    ); // For selected state
    final TextStyle bodyRegularWithColor = AppTextStyles.bodyRegular.copyWith(
      color: primaryTextColor,
    );
    final TextStyle bodySmallWithColor = AppTextStyles.bodySmall.copyWith(
      color: secondaryTextColor,
    );
    final TextStyle captionLargeMediumWithThemeColor = AppTextStyles
        .captionLargeMedium
        .copyWith(color: secondaryTextColor);

    return base
        .copyWith(
          // Material Design 3 type scale names. Map your custom styles here.
          // https://m3.material.io/styles/typography/type-scale-tokens
          displayLarge: base.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ), // Example: 57.sp
          displayMedium: base.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ), // Example: 45.sp
          displaySmall: base.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ), // Example: 36.sp

          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ), // Example: 32.sp
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ), // Example: 28.sp
          headlineSmall: headerWithColor,

          titleLarge: titleWithColor, // Your TextTitle (16sp, semibold)
          titleMedium: labelWithColor, // Your TextLabel (14sp, medium)
          titleSmall: captionLargeMediumWithThemeColor,
          bodyLarge: bodyRegularWithColor, // Your bodyRegular (16sp, regular)
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: primaryTextColor,
          ), // Default body (14sp)
          bodySmall: bodySmallWithColor, // Your bodySmall (12sp, regular)

          labelLarge:
              tabWithColor, // Your TextTab (14sp, medium), good for buttons, selected tabs
          labelMedium: base.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
            color: primaryTextColor,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 11.sp,
            color: secondaryTextColor,
          ),
        )
        .apply(
          fontFamily:
              'Inter', // Default font family for all text styles if not overridden
          bodyColor: primaryTextColor, // Default color for bodyText styles
          displayColor:
              primaryTextColor, // Default color for display, headline, title styles
        );
  }

  static RadioThemeData _buildRadioTheme(ColorScheme colorScheme) {
    return RadioThemeData(
      // Use MaterialStateProperty to define colors based on the radio's state
      fillColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        // If the radio button is selected, use our custom light pink background
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        // For the unselected state, use the theme's standard outline/border color
        // This ensures unselected radio buttons look consistent with the theme
        return colorScheme.outline;
      }),
    );
  }

  static AppBarTheme _buildAppBarTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2.0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      titleTextStyle: AppTextStyles.textTitle.copyWith(
        // Using your textTitle style
        color: colorScheme.onSurface,
      ),
    );
  }

  static CardThemeData _buildCardTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return CardThemeData(
      elevation: AppDimensions.elevationLow,
      margin: AppDimensions.edgeInsetsSmall,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLarge,
      ),
      color: colorScheme.surface,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: AppDimensions.elevationLow,
        padding: AppDimensions.buttonPadding,
        minimumSize: Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMedium,
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        textStyle:
            AppTextStyles.textLabel, // Using your textLabel style for buttons
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: AppDimensions.buttonPadding,
        minimumSize: Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMedium,
        ),
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        textStyle: AppTextStyles.textLabel, // Using your textLabel style
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: AppDimensions.buttonPadding,
        minimumSize: Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMedium,
        ),
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        textStyle: AppTextStyles.textLabel, // Using your textLabel style
        side: BorderSide(color: colorScheme.outline),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.12),
            );
          }
          if (states.contains(WidgetState.pressed)) {
            return BorderSide(color: colorScheme.primary, width: 2.w);
          }
          return BorderSide(color: colorScheme.outline);
        }),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    final commonBorder = OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusMedium,
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.7),
        width: AppDimensions.borderWidth,
      ),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor:
          colorScheme.surface, // Or a slightly different variant if needed
      contentPadding: AppDimensions.inputFieldContentPadding,
      border: commonBorder,
      enabledBorder: commonBorder,
      focusedBorder: commonBorder.copyWith(
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: AppDimensions.focusedBorderWidth,
        ),
      ),
      errorBorder: commonBorder.copyWith(
        borderSide: BorderSide(
          color: colorScheme.error,
          width: AppDimensions.borderWidth,
        ),
      ),
      focusedErrorBorder: commonBorder.copyWith(
        borderSide: BorderSide(
          color: colorScheme.error,
          width: AppDimensions.focusedBorderWidth,
        ),
      ),
      disabledBorder: commonBorder.copyWith(
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      labelStyle: AppTextStyles.textLabel.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      hintStyle: AppTextStyles.textLabel.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      floatingLabelStyle: AppTextStyles.textLabel.copyWith(
        color: colorScheme.primary,
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: colorScheme.error,
        fontSize: 12.sp,
      ), // Smaller error text
      helperStyle: AppTextStyles.bodySmall.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: 12.sp,
      ),
      isDense: true,
      constraints: BoxConstraints(minHeight: 44.h), // Ensure minimum height
    );
  }

  static ChipThemeData _buildChipTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
      selectedColor: colorScheme.primary,
      secondarySelectedColor: colorScheme.secondary,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingMicro,
      ),
      labelStyle: AppTextStyles.textLabel.copyWith(
        color: colorScheme.onSurfaceVariant,
      ), // Use textLabel
      secondaryLabelStyle: AppTextStyles.textLabel.copyWith(
        color: colorScheme.onSecondary,
      ),
      brightness: brightness,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCircular,
      ),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      selectedLabelStyle: AppTextStyles.textLabelTab.copyWith(
        fontSize: 12.sp,
      ), // Example: smaller for bottom nav
      unselectedLabelStyle: AppTextStyles.textLabelTab.copyWith(
        fontSize: 12.sp,
        color: colorScheme.onSurfaceVariant,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
    );
  }

  static TabBarThemeData _buildTabBarTheme(ColorScheme colorScheme) {
    return TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      labelStyle: AppTextStyles.textTab.copyWith(
        color: colorScheme.primary,
      ), // Your textTab style
      unselectedLabelStyle: AppTextStyles.textTab.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: colorScheme.primary, width: 2.0.w),
      ),
    );
  }
}
