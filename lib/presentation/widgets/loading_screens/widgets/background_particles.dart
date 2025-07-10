import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../presentation/utils/animations/loading_animation_controller.dart';

/// Animated background particles for the loading screen
class BackgroundParticles extends StatelessWidget {
  /// Animation controller
  final LoadingAnimationController animationController;

  const BackgroundParticles({
    super.key,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random(42);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Stack(
      children: List.generate(20, (index) {
        final size = random.nextDouble() * 6 + 2;
        final left = random.nextDouble() * screenWidth;
        final top = random.nextDouble() * screenHeight;
        final opacity = random.nextDouble() * 0.5 + 0.1;
        
        return Positioned(
          left: left,
          top: top,
          child: AnimatedBuilder(
            animation: animationController.floatController,
            builder: (context, child) {
              final floatValue = math.sin((animationController.floatController.value + index / 20) * math.pi * 2) * 20;
              
              return Transform.translate(
                offset: Offset(0, floatValue),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(opacity),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(opacity * 0.5),
                        blurRadius: size * 2,
                        spreadRadius: size * 0.5,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
} 