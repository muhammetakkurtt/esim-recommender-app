import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/styles/form_styles.dart';

/// Form submit button widget
class SubmitButton extends StatelessWidget {
  /// Button text
  final String text;
  
  /// Leading icon
  final IconData icon;
  
  /// Button click function
  final VoidCallback? onPressed;
  
  /// Loading state
  final bool isLoading;
  
  /// Loading text
  final String loadingText;
  
  /// Loading subtext
  final String loadingSubtext;

  const SubmitButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.loadingText = 'Processing...',
    this.loadingSubtext = 'Please wait',
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      transform: Matrix4.translationValues(0, isLoading ? 20 : 0, 0),
      height: 60,
      width: double.infinity,
      decoration: FormStyles.buttonContainerDecoration,
      child: ElevatedButton(
        onPressed: isLoading 
          ? null 
          : () {
            if (onPressed != null) {
              // Haptic feedback
              HapticFeedback.mediumImpact();
              onPressed!();
            }
          },
        style: FormStyles.primaryButtonStyle.copyWith(
          backgroundColor: isLoading 
              ? MaterialStateProperty.all(Colors.grey.shade400)
              : MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return const Color(0xFF4551CC);
                  }
                  return FormStyles.primaryColor;
                }),
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
        ),
        child: isLoading 
          ? _buildLoadingState()
          : _buildNormalState(),
      ),
    );
  }
  
  /// Loading state widget
  Widget _buildLoadingState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 24, 
          height: 24, 
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          )
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 120,
          height: 36,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$loadingText\n',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: loadingSubtext,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Normal state widget
  Widget _buildNormalState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated icon
        AnimatedRotation(
          turns: 0.05,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            icon, 
            size: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 14),
        // Main text
        Text(
          text, 
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        // Forward icon
        Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
} 