import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/esim_recommender_model.dart';
import '../widgets/loading_screens/ai_recommendation_loading_screen.dart';
import 'trip_info_form.dart';
import 'recommendation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ESIMRecommenderModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildMainContent(model),
      ),
    );
  }
  
  /// Method to build the main content
  Widget _buildMainContent(ESIMRecommenderModel model) {
    // Is the loading screen visible?
    if (model.isLoadingScreenVisible) {
      return const AIRecommendationLoadingScreen();
    }
    
    // Is there a recommendation?
    if (model.recommendation.isNotEmpty && model.recommendation['recommended_plan'] != null) {
      return const RecommendationScreen();
    }
    
    // Show the form screen by default
    return const TripInfoForm();
  }
} 