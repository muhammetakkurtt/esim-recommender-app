import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../presentation/utils/animations/loading_animation_controller.dart';
import '../../../utils/styles/loading_screen_styles.dart';

/// Animated widget that displays the loading message
class LoadingMessageWidget extends StatelessWidget {
  /// Message to be displayed
  final String message;
  
  /// Message index (for animation key)
  final int messageIndex;
  
  /// Animation controller
  final LoadingAnimationController animationController;

  const LoadingMessageWidget({
    super.key,
    required this.message,
    required this.messageIndex,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: LoadingScreenStyles.messageContainerDecoration,
        child: SizedBox(
          height: 50,
          child: AnimatedSwitcher(
            duration: LoadingScreenStyles.messageSwitchDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation, 
                      curve: LoadingScreenStyles.elasticCurve,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<int>(messageIndex),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Small animated icon
                  _buildAnimatedIcon(),
                  
                  const SizedBox(width: 16),
                  
                  // Message text
                  _buildMessageText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Animated icon
  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: animationController.pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LoadingScreenStyles.accentColor2.withOpacity(0.15 + animationController.pulseController.value * 0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: LoadingScreenStyles.accentColor2.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: animationController.rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: animationController.rotationController.value * 2 * math.pi,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return SweepGradient(
                      colors: [
                        LoadingScreenStyles.accentColor1,
                        LoadingScreenStyles.accentColor2,
                        LoadingScreenStyles.accentColor1,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      transform: GradientRotation(animationController.rotationController.value * math.pi),
                    ).createShader(bounds);
                  },
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  /// Message text
  Widget _buildMessageText() {
    return Expanded(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: const [
              Colors.white,
              Colors.white70,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds);
        },
        child: Text(
          message,
          style: LoadingScreenStyles.messageStyle,
        ),
      ),
    );
  }
} 