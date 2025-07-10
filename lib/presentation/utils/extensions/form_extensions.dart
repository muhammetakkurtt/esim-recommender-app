import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../styles/form_styles.dart';

/// Extension class for FormBuilder operations
extension FormBuilderExtensions on GlobalKey<FormBuilderState> {
  /// Validates form values and returns the result
  bool validateAndSave() {
    return currentState?.saveAndValidate() ?? false;
  }
  
  /// Returns form data as a Map
  Map<String, dynamic> get formData {
    return currentState?.value ?? {};
  }
  
  /// Returns the value of a specific field
  dynamic getFieldValue(String fieldName) {
    return currentState?.fields[fieldName]?.value;
  }
  
  /// Updates the value of a specific field
  void updateFieldValue(String fieldName, dynamic value) {
    currentState?.fields[fieldName]?.didChange(value);
  }
  
  /// Clears all form fields
  void resetForm() {
    currentState?.reset();
  }
}

/// Extension class for error notifications
extension SnackBarExtensions on BuildContext {
  /// Shows an error SnackBar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      FormStyles.buildErrorSnackBar(message),
    );
  }
  
  /// Shows a success SnackBar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }
  
  /// Provides haptic feedback
  void hapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.success:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.error:
        HapticFeedback.vibrate();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }
}

/// Types of haptic feedback
enum HapticFeedbackType {
  success,
  error,
  selection,
  light,
  heavy,
} 