import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/esim_recommender_model.dart';
import '../widgets/recommendation/constants.dart';
import '../widgets/recommendation/error_screen.dart';
import '../widgets/recommendation/explanation_card.dart';
import '../widgets/recommendation/recommendation_card.dart';
import '../widgets/recommendation/recommendation_model.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ESIMRecommenderModel>(context);
    final recommendation = model.recommendation;
    
    // Empty check
    if (recommendation.isEmpty) {
      // Go back to TripInfoForm only in case of an empty model state
      Future.microtask(() => model.setRecommendation({}));
      return Container();
    }
    
    // Structure the data
    final RecommendationResponse response = RecommendationResponse.fromJson(recommendation);
    
    // Error check
    if (response.hasError) {
      return ErrorScreen(
        message: response.errorMessage ?? 'An error occurred.',
        onRetry: () => model.setRecommendation({}),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      'Best eSIM Plan for Your Trip',
                      style: RecommendationTextStyles.heading,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Main recommendation card
                  if (response.hasRecommendation)
                    Hero(
                      tag: 'main_recommendation',
                      child: RecommendationCard(
                        recommendation: response.recommendedPlan!.toJson(),
                        isMainRecommendation: true,
                      ),
                    ),
                  
                  // Alternative plans button
                  if (response.hasAlternatives) ...[
                    const SizedBox(height: 24),
                    _buildAlternativesButton(context, response.alternativePlans),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // AI Explanation
                  ExplanationCard(explanation: response.explanation),
                  
                  const SizedBox(height: 40),
                  
                  // New recommendation button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text(
                              'Get New Recommendation', 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )
                            ),
                            onPressed: () {
                              // First clear model data, then change page
                              model.setRecommendation({});
                              // Update model with a slight delay 
                              Future.microtask(() => model.updateFormData({}));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RecommendationColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 4,
                              shadowColor: RecommendationColors.primary.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Alternative plans button
  Widget _buildAlternativesButton(BuildContext context, List<RecommendationPlan> alternativePlans) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.list_alt, color: Colors.white),
        label: const Text(
          'View Alternative Plans',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () => _showAlternativesSheet(context, alternativePlans),
        style: ElevatedButton.styleFrom(
          backgroundColor: RecommendationColors.primary.withOpacity(0.9),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 2,
          shadowColor: RecommendationColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  // BottomSheet for alternative plans
  void _showAlternativesSheet(BuildContext context, List<RecommendationPlan> plans) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,  // Occupy 60% of the screen
        minChildSize: 0.3,      // Minimum 30% visible
        maxChildSize: 0.9,      // Can grow up to 90%
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grip/handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 15),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${plans.length} Alternative Plans',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: RecommendationColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // List of alternative plans
                Expanded(
                  child: plans.isEmpty
                    ? const Center(child: Text('No alternative plans found.'))
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: RecommendationCard(
                              recommendation: plans[index].toJson(),
                              isMainRecommendation: false,
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 