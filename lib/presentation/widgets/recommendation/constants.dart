import 'package:flutter/material.dart';

class RecommendationColors {
  static const Color primary = Color(0xFF5D69E3);
  static const Color background = Colors.white;
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Colors.grey;
}

class RecommendationSizes {
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;
}

class RecommendationTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: RecommendationSizes.fontSizeXLarge,
    fontWeight: FontWeight.bold,
    color: RecommendationColors.primary,
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: RecommendationSizes.fontSizeLarge,
    fontWeight: FontWeight.bold,
    color: RecommendationColors.primary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: RecommendationSizes.fontSizeMedium,
    color: RecommendationColors.textPrimary,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: RecommendationSizes.fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: RecommendationColors.textSecondary,
  );
}

class RecommendationAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
} 