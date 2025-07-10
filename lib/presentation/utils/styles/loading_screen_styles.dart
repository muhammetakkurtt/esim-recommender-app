import 'package:flutter/material.dart';

/// Style class for the AI loading screen
class LoadingScreenStyles {
  LoadingScreenStyles._();
  
  /// Main theme color
  static const Color primaryColor = Color(0xFF6C63FF);
  
  /// Secondary theme color
  static const Color secondaryColor = Color(0xFF4A46B8);
  
  /// Accent colors
  static const Color accentColor1 = Color(0xFFFF5EAA);
  static const Color accentColor2 = Color(0xFF19D3C5);
  
  /// Background gradient
  static LinearGradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F1530),
      Color(0xFF080C1C),
      Color(0xFF050914),
    ],
  );
  
  /// Container decoration for the header
  static BoxDecoration get headerContainerDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accentColor1.withOpacity(0.2),
        accentColor1.withOpacity(0.1),
        accentColor2.withOpacity(0.05),
      ],
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ],
  );
  
  /// Title text style
  static const TextStyle titleStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  /// Message style
  static TextStyle get messageStyle => const TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
    fontFamily: 'Inter',
  );
  
  /// Subtext style
  static TextStyle get subtextStyle => const TextStyle(
    fontSize: 14,
    color: Colors.white70,
    fontFamily: 'Inter',
  );
  
  /// Container decoration for the AI icon
  static BoxDecoration get aiIconContainerDecoration => BoxDecoration(
    shape: BoxShape.circle,
    gradient: const RadialGradient(
      colors: [Colors.white, Color(0xFFF5F5FF)],
      stops: [0.5, 1.0],
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.5),
        blurRadius: 25,
        spreadRadius: 5,
      ),
      BoxShadow(
        color: accentColor1.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(-5, -5),
      ),
      BoxShadow(
        color: accentColor2.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(5, 5),
      ),
    ],
  );
  
  /// Rotating particle decoration
  static BoxDecoration particleDecoration(int index) {
    final baseColors = [
      accentColor1,
      accentColor2,
      primaryColor,
      const Color(0xFFFFFFFF),
    ];
    
    final color = baseColors[index % baseColors.length];
    
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color,
          color.withOpacity(0.7),
        ],
        stops: const [0.5, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.7),
          blurRadius: 8,
          spreadRadius: 0.5,
        ),
      ],
    );
  }
  
  /// Decoration for the glow effect
  static BoxDecoration get glowEffectDecoration => BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(
      colors: [
        primaryColor.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: const [0.1, 1.0],
    ),
  );
  
  /// Progress indicator container decoration
  static BoxDecoration get progressContainerDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: Colors.black.withOpacity(0.15),
    border: Border.all(
      color: Colors.white.withOpacity(0.05),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 5),
      ),
    ],
  );
  
  /// Progress bar background style
  static BoxDecoration get progressBarBackgroundDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.black.withOpacity(0.2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 1),
        spreadRadius: 0,
      ),
    ],
  );
  
  /// Progress bar foreground style
  static BoxDecoration get progressBarForegroundDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        accentColor2, 
        accentColor1,
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: accentColor2.withOpacity(0.5),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );
  
  /// Loading indicator colors
  static List<Color> get progressIndicatorGradient => [
    accentColor2,
    primaryColor,
    accentColor1,
  ];
  
  /// Animation durations
  static const Duration rotationDuration = Duration(milliseconds: 20000);
  static const Duration pulseDuration = Duration(milliseconds: 1500);
  static const Duration messageSwitchDuration = Duration(milliseconds: 400);
  static const Duration messageDisplayDuration = Duration(seconds: 3);
  static const Duration progressAnimationDuration = Duration(milliseconds: 1500);
  static const Duration shimmerDuration = Duration(milliseconds: 1800);
  
  /// Animation curves
  static const Curve mainCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve elasticCurve = Curves.elasticOut;
  
  /// Message section decoration
  static BoxDecoration get messageContainerDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: Colors.black.withOpacity(0.15),
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 5),
      ),
    ],
  );
  
  /// Button style
  static ButtonStyle get actionButtonStyle => ButtonStyle(
    backgroundColor: MaterialStateProperty.all(primaryColor),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    overlayColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return Colors.white.withOpacity(0.2);
      }
      return null;
    }),
    elevation: MaterialStateProperty.all(0),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  );
} 