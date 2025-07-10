import 'package:flutter/material.dart';

import '../../../../presentation/utils/animations/loading_animation_controller.dart';
import '../../../utils/styles/loading_screen_styles.dart';

class AnimatedAIProgressIndicator extends StatelessWidget {
  /// Animation controller
  final LoadingAnimationController animationController;

  const AnimatedAIProgressIndicator({
    super.key,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: LoadingScreenStyles.progressContainerDecoration,
        child: Column(
          children: [
            _buildProgressBar(),
            
            const SizedBox(height: 16),

            _buildIndicatorInfo(),
          ],
        ),
      ),
    );
  }
  
  /// Progress bar
  Widget _buildProgressBar() {
    return SizedBox(
      height: 12,
      child: Stack(
        children: [
          Container(
            decoration: LoadingScreenStyles.progressBarBackgroundDecoration,
          ),

          _buildMovingProgressIndicator(),

          _buildShimmerEffect(),
        ],
      ),
    );
  }
  
  /// Moving progress indicator
  Widget _buildMovingProgressIndicator() {
    return AnimatedBuilder(
      animation: animationController.progressController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            final angle = animationController.progressController.value * 6.28; // 2π
            
            return LinearGradient(
              colors: LoadingScreenStyles.progressIndicatorGradient,
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: GradientRotation(angle),
            ).createShader(bounds);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
  
  /// Shimmer glow effect
  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: animationController.shimmerController,
      builder: (context, child) {
        return Positioned.fill(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              final position = animationController.shimmerController.value;
              
              return LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.4),
                  Colors.transparent,
                ],
                stops: [
                  (position - 0.3).clamp(0.0, 1.0),
                  position,
                  (position + 0.3).clamp(0.0, 1.0),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Indicator information
  Widget _buildIndicatorInfo() {
    return Center(
      child: AnimatedBuilder(
        animation: animationController.pulseController,
        builder: (context, child) {
          final pulseOpacity = (0.5 + animationController.pulseController.value * 0.5).clamp(0.0, 1.0);
          final shadowOpacity = (0.3 + animationController.pulseController.value * 0.2).clamp(0.0, 1.0);
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPulsingDot(pulseOpacity, shadowOpacity),
              
              const SizedBox(width: 10),
              
              _buildInfoText(),
            ],
          );
        },
      ),
    );
  }
  
  /// Pulsing dot
  Widget _buildPulsingDot(double pulseOpacity, double shadowOpacity) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LoadingScreenStyles.accentColor1.withOpacity(pulseOpacity),
        boxShadow: [
          BoxShadow(
            color: LoadingScreenStyles.accentColor1.withOpacity(shadowOpacity),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
  
  /// Info text
  Widget _buildInfoText() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [
            LoadingScreenStyles.accentColor1,
            Colors.white.withOpacity(0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds);
      },
      child: const Text(
        'AI is analyzing the best plans',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
} 