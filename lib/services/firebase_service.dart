import '../models/esim_plan.dart';
import 'apify_service.dart';
import 'gemini_service.dart';

class FirebaseService {
  // Create eSIM recommendation
  static Future<Map<String, dynamic>> getESIMRecommendation({
    required String country,
    required int tripDuration,
    required double dataNeeded,
    required double budget,
  }) async {
    try {
      // Create recommendation locally
      return _getLocalRecommendation(
        country: country, 
        tripDuration: tripDuration, 
        dataNeeded: dataNeeded, 
        budget: budget
      );
    } catch (e) {
      print('Recommendation creation error: $e');
      return {
        'error': true,
        'message': 'An error occurred during the recommendation process: ${e.toString()}'
      };
    }
  }
  
  // Create recommendation locally
  static Future<Map<String, dynamic>> _getLocalRecommendation({
    required String country,
    required int tripDuration,
    required double dataNeeded,
    required double budget,
  }) async {
    try {
      // 1. Fetch eSIM plans from Apify
      final plans = await ApifyService.fetchESIMPlans(country);
      
      // 2. Filter based on user criteria
      final filteredPlans = ApifyService.filterPlans(
        plans: plans,
        tripDuration: tripDuration,
        dataNeeded: dataNeeded,
        budget: budget,
      );
      
      // Filtered plan count information
      int maxPlansToProcess = filteredPlans.length; // Process all filtered plans
      int maxTopPlans = 2000; // Maximum number of top plans to send to LLM
      
      print('Found and will evaluate a total of ${filteredPlans.length} plans.');
      
      if (filteredPlans.isEmpty) {
        // If no plans found, do a broader search
        // Filter again with more flexible criteria
        print('No plans found matching the specified criteria, expanding criteria...');
        double relaxedDataNeeded = dataNeeded * 0.9; // 10% less data
        double relaxedBudget = budget * 1.1; // 10% more budget
        
        final relaxedFilteredPlans = plans.where((plan) {
          return plan.validityDays >= tripDuration &&
                plan.dataLimit >= relaxedDataNeeded &&
                (plan.promoPrice ?? plan.priceUSD) <= relaxedBudget;
        }).toList();
        
        if (relaxedFilteredPlans.isNotEmpty) {
          print('Found ${relaxedFilteredPlans.length} plans with expanded criteria.');
          final topPlans = ApifyService.getBestPlans(relaxedFilteredPlans, maxTopPlans);
          
          // Determine the best plan with Gemini
          return await GeminiService.getRecommendation(
            country: country,
            tripDuration: tripDuration,
            dataNeeded: dataNeeded,
            budget: budget,
            topPlans: topPlans,
          );
        }
        
        return {
          'error': true,
          'message': 'No plans found matching the specified criteria. Please broaden your criteria.'
        };
      }
      
      // Sort the best plans with more detailed criteria
      final topPlans = ApifyService.getBestPlans(filteredPlans, maxTopPlans);
      
      if (topPlans.isEmpty) {
        return {
          'error': true,
          'message': 'No plans found matching the specified criteria. Please broaden your criteria.'
        };
      }
      
      // Determine the best plan with Gemini
      return await GeminiService.getRecommendation(
        country: country,
        tripDuration: tripDuration,
        dataNeeded: dataNeeded,
        budget: budget,
        topPlans: topPlans,
      );
    } catch (e) {
      print('Local recommendation creation error: $e');
      return {
        'error': true,
        'message': 'An error occurred during the recommendation process: ${e.toString()}'
      };
    }
  }
} 