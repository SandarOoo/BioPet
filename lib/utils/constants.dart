import 'package:flutter/material.dart';

/// App-wide color constants
class AppColors {
  // Main palette from the reference image
  static const Color emerald = Color(0xFF065F46);
  static const Color mint = Color(0xFFA7F3D0);
  static const Color cream = Color(0xFFFFF8E7);

  // Background colors
  static const Color backgroundColor = cream;
  static const Color scaffoldBackgroundColor = cream;

  // Card and surface colors
  static const Color cardColor = Colors.white;
  static const Color cardBackgroundColor = Color(0xFFF0FDF4);
  static const Color mintSurface = Color(0xFFE6FFF5);

  // Primary colors
  static const Color primaryColor = emerald;
  static const Color secondaryColor = mint;

  // Text colors
  static const Color primaryTextColor = Color(0xFF102A24);
  static const Color secondaryTextColor = Color(0xFF4B635B);
  static const Color textOnEmerald = Colors.white;

  // Border and divider colors
  static const Color borderColor = Color(0xFFCDEBDD);
  static const Color dividerColor = Color(0xFFDDEFE6);

  // Action colors
  static const Color deleteIconColor = Color(0xFFDC2626);
  static const Color successColor = emerald;

  /*
   * Old names kept to prevent errors in existing pages.
   * You can remove these after updating all page references.
   */
  static const Color darkBackground = backgroundColor;
  static const Color darkBlueBackground = scaffoldBackgroundColor;
  static const Color primaryBlue = primaryColor;
  static const Color secondaryBlue = secondaryColor;
  static const Color lightTextColor = primaryTextColor;
  static const Color faintTextColor = secondaryTextColor;
}

/// App-wide text styles
class AppTextStyles {
  static const TextStyle mainTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.emerald,
  );

  static const TextStyle subTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryTextColor,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle smallText = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryTextColor,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}