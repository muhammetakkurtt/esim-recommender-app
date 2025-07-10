import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:lottie/lottie.dart';
import '../../utils/styles/loading_screen_styles.dart';
import 'widgets/background_particles.dart';
import 'widgets/ai_animation_widget.dart';
import 'widgets/loading_message_widget.dart';
import 'widgets/animated_ai_progress_indicator.dart';
import '../../../presentation/utils/animations/loading_animation_controller.dart';

/// Animated loading screen to show while AI recommendation is loading
class AIRecommendationLoadingScreen extends StatefulWidget {
  /// List of loading status messages
  final List<String> loadingMessages;
  
  const AIRecommendationLoadingScreen({
    super.key,
    this.loadingMessages = const [
      'Analyzing your personal preferences...',
      'Scanning eSIM operators...',
      'Calculating best price-performance ratio...',
      'Creating personalized recommendations...',
    ],
  });

  @override
  State<AIRecommendationLoadingScreen> createState() => _AIRecommendationLoadingScreenState();
}

class _AIRecommendationLoadingScreenState extends State<AIRecommendationLoadingScreen> 
    with TickerProviderStateMixin {
  late final LoadingAnimationController _animationController;
  int _currentMessageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = LoadingAnimationController(vsync: this);
    
    // Change messages at specific intervals
    _startMessageTimer();
  }
  
  void _startMessageTimer() {
    Future.delayed(LoadingScreenStyles.messageDisplayDuration, () {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % widget.loadingMessages.length;
        });
        _startMessageTimer();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LoadingScreenStyles.backgroundGradient,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            
            BackgroundParticles(animationController: _animationController),
            
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    
                    AIAnimationWidget(animationController: _animationController),
                    
                    const SizedBox(height: 40),
                    
                    LoadingMessageWidget(
                      message: widget.loadingMessages[_currentMessageIndex],
                      messageIndex: _currentMessageIndex,
                      animationController: _animationController,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    AnimatedAIProgressIndicator(animationController: _animationController),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 