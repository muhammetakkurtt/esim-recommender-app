import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Extension methods for Widgets
extension WidgetExtensions on Widget {
  /// Wraps the widget in a container with margin
  Widget withMargin({EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 24)}) {
    return Padding(
      padding: margin,
      child: this,
    );
  }
  
  /// Adds haptic feedback
  Widget withHapticFeedback(HapticFeedbackType type) {
    return GestureDetector(
      onTap: () {
        switch (type) {
          case HapticFeedbackType.light:
            HapticFeedback.lightImpact();
            break;
          case HapticFeedbackType.medium:
            HapticFeedback.mediumImpact();
            break;
          case HapticFeedbackType.heavy:
            HapticFeedback.heavyImpact();
            break;
          case HapticFeedbackType.selection:
            HapticFeedback.selectionClick();
            break;
          case HapticFeedbackType.vibrate:
            HapticFeedback.vibrate();
            break;
        }
      },
      child: this,
    );
  }
  
  /// Adds background decoration
  Widget withDecoration(BoxDecoration decoration) {
    return Container(
      decoration: decoration,
      child: this,
    );
  }
  
  /// Applies rotation animation
  Widget withRotationAnimation({
    required AnimationController controller,
    double? startAngle,
    double? endAngle,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: startAngle != null && endAngle != null
              ? startAngle + controller.value * (endAngle - startAngle)
              : controller.value * 2 * 3.14159,
          child: child,
        );
      },
      child: this,
    );
  }
}

/// Types of haptic feedback
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
} 