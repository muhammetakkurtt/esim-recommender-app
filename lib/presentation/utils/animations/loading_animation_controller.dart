import 'package:flutter/material.dart';
import '../styles/loading_screen_styles.dart';

/// Central controller class that manages all animations in the loading screen
class LoadingAnimationController {
  /// Controller for the main rotation animation
  late final AnimationController rotationController;
  
  /// Controller for the breathing animation
  late final AnimationController pulseController;
  
  /// Controller for the floating up and down animation
  late final AnimationController floatController;
  
  /// Controller for the progress bar animation
  late final AnimationController progressController;
  
  /// Animation controller for the shimmer effect
  late final AnimationController shimmerController;
  
  /// Initializes all animation controllers with a single vsync source
  LoadingAnimationController({required TickerProvider vsync}) {
    // Main rotation animation
    rotationController = AnimationController(
      vsync: vsync,
      duration: LoadingScreenStyles.rotationDuration,
    )..repeat();
    
    // Breathing animation
    pulseController = AnimationController(
      vsync: vsync,
      duration: LoadingScreenStyles.pulseDuration,
    )..repeat(reverse: true);
    
    // Floating up and down animation
    floatController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    
    // Progress bar animation
    progressController = AnimationController(
      vsync: vsync,
      duration: LoadingScreenStyles.progressAnimationDuration,
    )..repeat();
    
    // Animation for the shimmer effect
    shimmerController = AnimationController(
      vsync: vsync,
      duration: LoadingScreenStyles.shimmerDuration,
    )..repeat();
  }
  
  /// Disposes all animation controllers
  void dispose() {
    rotationController.dispose();
    pulseController.dispose();
    floatController.dispose();
    progressController.dispose();
    shimmerController.dispose();
  }
} 