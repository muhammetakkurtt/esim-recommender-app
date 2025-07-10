import 'package:flutter/material.dart';

/// Common style class for form components
class FormStyles {
  FormStyles._();
  
  static const Color primaryColor = Color(0xFF5D69E3);
  static const Color errorColor = Colors.red;
  
  /// Container decoration for form field
  static BoxDecoration get formFieldContainerDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 15,
        offset: const Offset(0, 5),
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.7),
        blurRadius: 15,
        offset: const Offset(0, -5),
        spreadRadius: 1,
      ),
    ],
  );
  
  /// Basic input decoration
  static InputDecoration inputDecoration({
    required String labelText,
    required IconData prefixIconData,
    IconData? suffixIconData,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: errorText != null ? errorColor : Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
      errorText: errorText,
      prefixIcon: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(prefixIconData, color: errorText != null ? errorColor : primaryColor, size: 20),
      ),
      suffixIcon: suffixIconData != null 
        ? Icon(suffixIconData, color: primaryColor) 
        : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
  
  /// Title style
  static ShaderMask buildGradientTitle(String text) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [primaryColor, Colors.purple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 26, 
          fontWeight: FontWeight.bold, 
          color: Colors.white
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// Button style
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
  );
  
  /// Button container decoration
  static BoxDecoration get buttonContainerDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
    ],
  );
  
  /// Error SnackBar
  static SnackBar buildErrorSnackBar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      elevation: 4,
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
  }
} 