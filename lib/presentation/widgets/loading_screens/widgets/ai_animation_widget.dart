import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:lottie/lottie.dart';

import '../../../../presentation/utils/animations/loading_animation_controller.dart';
import '../../../utils/styles/loading_screen_styles.dart';

/// Widget containing the AI animation
class AIAnimationWidget extends StatelessWidget {
  /// Animation controller
  final LoadingAnimationController animationController;

  const AIAnimationWidget({
    super.key,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController.floatController,
      builder: (context, child) {
        // Floating up and down animation
        return Transform.translate(
          offset: Offset(0, animationController.floatController.value * 8 - 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wide glow effect
              Container(
                width: 340,
                height: 340,
                decoration: LoadingScreenStyles.glowEffectDecoration,
              ),
              
              // Middle glow effect
              Container(
                width: 280,
                height: 280,
                decoration: LoadingScreenStyles.glowEffectDecoration,
              ),
              
              // Background circle
              _buildBackgroundCircle(),
              
              // Rotating outer circle
              _buildOuterRotatingCircle(),
              
              // Middle rotating circle
              _buildMiddleRotatingCircle(),
              
              // Inner circle
              _buildInnerRotatingCircle(),
              
              // Center AI icon
              _buildAIIcon(),
              
              // Rotating particles
              ..._buildParticles(),
            ],
          ),
        );
      },
    );
  }
  
  /// Background circle widget
  Widget _buildBackgroundCircle() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
  
  /// Outer rotating circle
  Widget _buildOuterRotatingCircle() {
    return AnimatedBuilder(
      animation: animationController.rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: animationController.rotationController.value * 2 * math.pi,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              gradient: SweepGradient(
                center: Alignment.center,
                startAngle: 0,
                endAngle: 2 * math.pi,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.0),
                  LoadingScreenStyles.accentColor2.withOpacity(0.8),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.25, 0.5, 0.85, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Middle rotating circle
  Widget _buildMiddleRotatingCircle() {
    return AnimatedBuilder(
      animation: animationController.rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: -animationController.rotationController.value * 2 * math.pi * 0.7,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              gradient: SweepGradient(
                center: Alignment.center,
                startAngle: 0,
                endAngle: 2 * math.pi,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.0),
                  LoadingScreenStyles.accentColor1.withOpacity(0.7),
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Inner rotating circle
  Widget _buildInnerRotatingCircle() {
    return AnimatedBuilder(
      animation: animationController.rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: animationController.rotationController.value * 2 * math.pi * 0.5,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: LoadingScreenStyles.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Center AI icon
  Widget _buildAIIcon() {
    return AnimatedBuilder(
      animation: animationController.pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + animationController.pulseController.value * 0.05,
          child: Container(
            width: 140,
            height: 140,
            decoration: LoadingScreenStyles.aiIconContainerDecoration,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildIconBackgroundGlow(),  
                    _buildLottieAnimation(),
                    _buildShimmerEffect(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Icon background glow effect
  Widget _buildIconBackgroundGlow() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            LoadingScreenStyles.accentColor1.withOpacity(0.7),
            LoadingScreenStyles.accentColor2.withOpacity(0.4),
            Colors.transparent
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
  
  /// Lottie animation
  Widget _buildLottieAnimation() {
    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [
              LoadingScreenStyles.accentColor1,
              LoadingScreenStyles.accentColor2,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Lottie.asset(
          'assets/animations/travel_globe.json',
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      ),
    );
  }
  
  /// Shimmer glow effect
  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: animationController.shimmerController,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1 + animationController.shimmerController.value * 0.1),
                  Colors.transparent,
                ],
                stops: const [
                  0.1,
                  0.5,
                  0.9,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(animationController.shimmerController.value * math.pi * 2),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Rotating particles
  List<Widget> _buildParticles() {
    return List.generate(15, (index) {
      final angle = index * (math.pi / 7.5);
      return AnimatedBuilder(
        animation: animationController.rotationController,
        builder: (context, child) {
          final start = (index / 15);
          final end = math.min((start + 0.1), 1.0);
          
          final circleAnimation = Tween<double>(
            begin: 0.7,
            end: 1.2,
          ).animate(
            CurvedAnimation(
              parent: animationController.rotationController,
              curve: Interval(
                start,
                end,
                curve: LoadingScreenStyles.mainCurve,
              ),
            ),
          );
          
          final radius = 130 + (index % 4) * 20;
          
          return Transform.translate(
            offset: Offset(
              math.cos(angle + (animationController.rotationController.value * 2 * math.pi)) * radius,
              math.sin(angle + (animationController.rotationController.value * 2 * math.pi)) * radius,
            ),
            child: AnimatedBuilder(
              animation: animationController.pulseController,
              builder: (context, child) {
                final pulseValue = math.sin((animationController.pulseController.value + index / 15) * math.pi) * 0.2 + 0.8;
                
                return Transform.scale(
                  scale: circleAnimation.value * pulseValue,
                  child: Container(
                    width: 8 + (index % 4) * 3,
                    height: 8 + (index % 4) * 3,
                    decoration: LoadingScreenStyles.particleDecoration(index),
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }
} 