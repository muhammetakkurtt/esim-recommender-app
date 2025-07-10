import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../models/esim_plan.dart';
import 'dart:convert';

class GeminiService {
  static FirebaseVertexAI? _vertexAI;
  static GenerativeModel? _model;
  
  // Initialize Vertex AI service
  static void initialize() {
    _vertexAI = FirebaseVertexAI.instance;
    // Create Gemini model
    _model = _vertexAI!.generativeModel(
      model: 'gemini-2.5-pro',
      // System instruction to regulate model behavior
      systemInstruction: Content.text('Provide your answers as plain text as if you were speaking directly to the user. Do not use Markdown formatting, headings, asterisks, or list items. Write all your responses as plain, unformatted text. Use "HEADING:" format for headings. Do not use any markers for text sections. Present JSON data only in formatted code blocks.')
    );
  }

  // Evaluate eSIM plans with Gemini model and get recommendations
  static Future<Map<String, dynamic>> getRecommendation({
    required String country,
    required int tripDuration,
    required double dataNeeded,
    required double budget,
    required List<ESIMPlan> topPlans,
    String? criteriaNote,
  }) async {
    try {
      // Initialize the model if it hasn't been created
      if (_model == null) {
        initialize();
      }
      
      // Return error if no plans are available
      if (topPlans.isEmpty) {
        return {
          'error': true,
          'message': 'No eSIM plans found to process.'
        };
      }
      
      // Prepare prompt
      String prompt = _createPrompt(
        country: country,
        tripDuration: tripDuration,
        dataNeeded: dataNeeded,
        budget: budget,
        topPlans: topPlans,
        criteriaNote: criteriaNote,
      );

      // Call Gemini model with Firebase Vertex AI
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      // Get response
      final responseText = response.text;
      
      if (responseText != null) {
        // Parse response
        return _parseRecommendation(responseText, topPlans);
      } else {
        throw Exception('Vertex AI returned an empty response');
      }
    } catch (e) {
      print('Vertex AI error: $e');
      // Return error message
      return {
        'error': true,
        'message': 'An error occurred while creating the recommendation: ${e.toString()}'
      };
    }
  }

  // Create prompt for Gemini
  static String _createPrompt({
    required String country,
    required int tripDuration,
    required double dataNeeded,
    required double budget,
    required List<ESIMPlan> topPlans,
    String? criteriaNote,
  }) {
    StringBuffer prompt = StringBuffer();

    prompt.writeln('''You are a travel consultant and eSIM recommendation expert. In this role, you are working as an AI Agent.
You must analyze the user's needs and determine the most suitable eSIM plan for them.
Your decisions should consider the following criteria:
1. User's travel details (destination country, travel duration)
2. User's data needs (minimum GB)
3. User's budget (maximum USD)
4. Plan validity period's compatibility with the user's travel duration
5. Price-performance balance (cost per GB)
6. Additional plan advantages (tethering, low latency, etc.)
7. Provider reliability (certified?, popularity score)

Explain your decision-making process step by step in your response. Then, clearly state the best option and why you recommend it.

IMPORTANT: Write your response as plain text without formatting marks (such as *, #, -).
Divide your answer into sections, but use plain text with each section starting with "SECTION:" like this:

ANALYSIS SUMMARY: Brief evaluation (1-2 paragraphs)
BEST RECOMMENDATION: Indicate the most suitable plan and explain why. Don't use "Plan X" format, instead use the provider and plan name directly (for example: "Nomad Algeria").
ALTERNATIVE RECOMMENDATIONS: List the top 10 alternative options in order. Include a brief explanation for each.
PURCHASE TIPS: Provide useful tips for the user

Make a decision and provide a clear recommendation. Avoid ambiguous statements (I'm not sure, I need more information, etc.).

IMPORTANT: Do not use any plan numbers in your response (such as "Plan 1", "Plan 2", etc.). Instead, use the plan name and provider name directly.

IMPORTANT: At the end of your response, be sure to include the following structured format.
This format will be automatically processed by the system:

```json
{
  "recommended_plan_id": "PLAN_ID",
  "alternative_plan_id_1": "PLAN_ID_1",
  "alternative_plan_id_2": "PLAN_ID_2",
  "alternative_plan_id_3": "PLAN_ID_3",
  "alternative_plan_id_4": "PLAN_ID_4",
  "alternative_plan_id_5": "PLAN_ID_5",
  "alternative_plan_id_6": "PLAN_ID_6",
  "alternative_plan_id_7": "PLAN_ID_7",
  "alternative_plan_id_8": "PLAN_ID_8",
  "alternative_plan_id_9": "PLAN_ID_9",
  "alternative_plan_id_10": "PLAN_ID_10"
}
```

Use the above format and replace PLAN_ID with the actual ID of the plan you're recommending. This ID should be the sequence number of the plans in the list (1, 2, 3, ...).
For example, if you're recommending Plan 1, it should be "recommended_plan_id": "1".
''');
    
    prompt.writeln('\n## USER INFORMATION');
    prompt.writeln('Country: $country');
    prompt.writeln('Travel Duration: $tripDuration days');
    prompt.writeln('Data Needed: $dataNeeded GB (minimum)');
    prompt.writeln('Budget: $budget USD (maximum)');
    
    if (criteriaNote != null && criteriaNote.isNotEmpty) {
      prompt.writeln('Additional Criteria: $criteriaNote');
    }
    
    prompt.writeln('\n## AVAILABLE eSIM PLANS');
    prompt.writeln('Total ${topPlans.length} plans found.');
    
    // If there are too many plans (more than 50)
    bool hasManyPlans = topPlans.length > 50;
    int detailedPlanCount = hasManyPlans ? 50 : topPlans.length;
    
    // Show the top 50 plans in detail
    prompt.writeln('\n### Top $detailedPlanCount Plans - Comparison Table');
    prompt.writeln('| # | Provider | Plan Name | Data Limit | Validity | Price | Discounted Price | Cost per GB | Certified | Popularity | Features |');
    prompt.writeln('|---|----------|----------|-------------|------------|-------|-----------------|-------------------|-------------|------------|------------|');
    
    for (int i = 0; i < detailedPlanCount; i++) {
      ESIMPlan plan = topPlans[i];
      
      // Calculate price/GB ratio
      double pricePerGB = plan.pricePerGB;
      
      // Prepare features
      List<String> features = [];
      if (plan.tethering) features.add('Tethering');
      if (plan.isLowLatency) features.add('Low latency');
      if (plan.phoneNumber) features.add('Phone number');
      if (plan.canTopUp) features.add('Can top up');
      if (plan.has5G) features.add('5G');
      if (plan.internetBreakouts.isNotEmpty) features.add('${plan.internetBreakouts.length} internet breakouts');
      
      String featureText = features.isEmpty ? '-' : features.join(', ');
      String planName = plan.name ?? plan.enName ?? '-';
      
      prompt.writeln('| ${i+1} | ${plan.provider} | $planName | ${plan.dataLimit} GB | ${plan.validityDays} days | \$${plan.priceUSD.toStringAsFixed(2)} | ${plan.promoPrice != null ? '\$${plan.promoPrice!.toStringAsFixed(2)}' : '-'} | \$${pricePerGB.toStringAsFixed(2)}/GB | ${plan.isCertified ? 'Yes' : 'No'} | ${plan.popularity} | $featureText |');
    }
    
    // If there are too many plans, summarize the rest
    if (hasManyPlans) {
      prompt.writeln('\n### Summary Statistics for Remaining ${topPlans.length - detailedPlanCount} Plans');
      
      // Calculate average price, data limit, and validity period
      double avgPrice = 0;
      double avgDataLimit = 0;
      double avgValidityDays = 0;
      int certifiedCount = 0;
      
      for (int i = detailedPlanCount; i < topPlans.length; i++) {
        ESIMPlan plan = topPlans[i];
        avgPrice += (plan.promoPrice ?? plan.priceUSD);
        avgDataLimit += plan.dataLimit;
        avgValidityDays += plan.validityDays;
        if (plan.isCertified) certifiedCount++;
      }
      
      int remainingPlans = topPlans.length - detailedPlanCount;
      avgPrice /= remainingPlans;
      avgDataLimit /= remainingPlans;
      avgValidityDays /= remainingPlans;
      
      prompt.writeln('- Average Price: \$${avgPrice.toStringAsFixed(2)}');
      prompt.writeln('- Average Data Limit: ${avgDataLimit.toStringAsFixed(2)} GB');
      prompt.writeln('- Average Validity Period: ${avgValidityDays.toStringAsFixed(0)} days');
      prompt.writeln('- Number of Certified Providers: $certifiedCount/${remainingPlans}');
      
      // Price range
      double minPrice = double.infinity;
      double maxPrice = 0;
      for (int i = detailedPlanCount; i < topPlans.length; i++) {
        ESIMPlan plan = topPlans[i];
        double planPrice = (plan.promoPrice ?? plan.priceUSD);
        if (planPrice < minPrice) minPrice = planPrice;
        if (planPrice > maxPrice) maxPrice = planPrice;
      }
      prompt.writeln('- Price Range: \$${minPrice.toStringAsFixed(2)} - \$${maxPrice.toStringAsFixed(2)}');
    }
    
    // Detailed plan information (for top 50 plans)
    prompt.writeln('\n## DETAILED PLAN INFORMATION');
    for (int i = 0; i < detailedPlanCount; i++) {
      ESIMPlan plan = topPlans[i];
      String planName = plan.name ?? plan.enName ?? '';
      
      prompt.writeln('\n### PLAN ${i+1}: ${plan.provider} ${planName}');
      
      // Basic information
      prompt.writeln('- Data Limit: ${plan.dataLimit} GB');
      prompt.writeln('- Validity: ${plan.validityDays} days');
      
      // Price information
      prompt.writeln('- Regular Price: \$${plan.priceUSD.toStringAsFixed(2)}');
      if (plan.promoPrice != null) {
        prompt.writeln('- Discounted Price: \$${plan.promoPrice!.toStringAsFixed(2)}');
        
        if (plan.promoCode != null && plan.promoCode!.isNotEmpty) {
          prompt.writeln('- Promo Code: ${plan.promoCode}');
        }
        
        if (plan.promoExpiry != null && plan.promoExpiry!.isNotEmpty) {
          prompt.writeln('- Promo Expiry: ${plan.promoExpiry}');
        }
        
        if (plan.promoTitle != null && plan.promoTitle!.isNotEmpty) {
          prompt.writeln('- Promo Title: ${plan.promoTitle}');
        }
      }
      
      // Features
      prompt.writeln('- Certified Provider: ${plan.isCertified ? 'Yes' : 'No'}');
      prompt.writeln('- Popularity Score: ${plan.popularity}/100');
      
      if (plan.tethering) prompt.writeln('- Tethering: ${plan.tethering ? 'Supported' : 'Not supported'}');
      if (plan.isLowLatency) prompt.writeln('- Low Latency: ${plan.isLowLatency ? 'Yes' : 'No'}');
      if (plan.subscription) prompt.writeln('- Subscription: ${plan.subscription ? 'Required' : 'Not required'}');
      if (plan.phoneNumber) prompt.writeln('- Phone Number: ${plan.phoneNumber ? 'Included' : 'Not included'}');
      if (plan.canTopUp) prompt.writeln('- Top Up: ${plan.canTopUp ? 'Possible' : 'Not possible'}');
      
      if (plan.providerInfo.isNotEmpty) {
        prompt.writeln('- Provider Information: ${plan.providerInfo}');
      }
      
      if (plan.additionalInfo != null && plan.additionalInfo!.isNotEmpty) {
        prompt.writeln('- Additional Information: ${plan.additionalInfo}');
      }
    }
    
    prompt.writeln('\n## EVALUATION AND RECOMMENDATION');
    prompt.writeln('Please evaluate the above eSIM plans according to the user\'s needs and recommend the most suitable plan. Consider the following in your evaluation:');
    prompt.writeln('1. Is the plan\'s validity period sufficient for the user\'s $tripDuration-day trip?');
    prompt.writeln('2. Does it meet the ${dataNeeded} GB data need?');
    prompt.writeln('3. Is it within the $budget USD budget?');
    prompt.writeln('4. Which plan offers the best price/GB ratio?');
    prompt.writeln('5. Which plan\'s features are more advantageous for the user?');
    prompt.writeln('6. Are there special promotions? Do they create value for the user?');
    
    prompt.writeln('\n## STRUCTURE YOUR RESPONSE');
    prompt.writeln('Structure your response according to the following template:');
    prompt.writeln('1. **ANALYSIS SUMMARY**: Brief evaluation (1-2 paragraphs)');
    prompt.writeln('2. **BEST RECOMMENDATION**: Indicate the most suitable plan and explain why. Don\'t use "Plan X" format, instead use the provider and plan name directly (for example: "Nomad Algeria").');
    prompt.writeln('3. **ALTERNATIVE RECOMMENDATIONS**: List the top 10 alternative options in order. Include a brief explanation for each.');
    prompt.writeln('4. **PURCHASE TIPS**: Provide useful tips for the user');
    prompt.writeln('5. **JSON INFORMATION**: At the end of your response, specify the recommended and alternative plan IDs in JSON format (as shown below)');
    
    prompt.writeln('\n```json');
    prompt.writeln('{');
    prompt.writeln('  "recommended_plan_id": "X",');
    prompt.writeln('  "alternative_plan_id_1": "A",');
    prompt.writeln('  "alternative_plan_id_2": "B",');
    prompt.writeln('  "alternative_plan_id_3": "C",');
    prompt.writeln('  "alternative_plan_id_4": "D",');
    prompt.writeln('  "alternative_plan_id_5": "E",');
    prompt.writeln('  "alternative_plan_id_6": "F",');
    prompt.writeln('  "alternative_plan_id_7": "G",');
    prompt.writeln('  "alternative_plan_id_8": "H",');
    prompt.writeln('  "alternative_plan_id_9": "I",');
    prompt.writeln('  "alternative_plan_id_10": "J"');
    prompt.writeln('}');
    prompt.writeln('```');
    
    prompt.writeln('\nNote: Instead of X, A, B, C, D, E, F, G, H, I, J, you should write the actual sequence numbers (1, 2, 3, ...) of your recommended plans.');
    
    return prompt.toString();
  }

  // Parse LLM response
  static Map<String, dynamic> _parseRecommendation(String responseText, List<ESIMPlan> topPlans) {
    try {
      // Extract JSON block from text
      final RegExp jsonRegex = RegExp(r'```json\s*([\s\S]*?)\s*```');
      final match = jsonRegex.firstMatch(responseText);
      
      if (match != null) {
        final jsonString = match.group(1)!.trim();
        final Map<String, dynamic> planIds = json.decode(jsonString);
        
        // Get recommended plan ID
        String recommendedPlanId = planIds['recommended_plan_id'] ?? '';
        
        // Create list of alternative plans
        List<String> alternativePlanIds = [];
        for (int i = 1; i <= 10; i++) {
          final String key = 'alternative_plan_id_$i';
          if (planIds.containsKey(key) && planIds[key] != null) {
            alternativePlanIds.add(planIds[key]);
          }
        }
        
        // Find plans by ID and add to response
        Map<String, dynamic> result = {
          'explanation': responseText.replaceAll(match[0]!, '').trim(),
        };
        
        // Add recommended plan
        if (recommendedPlanId.isNotEmpty) {
          try {
            int index = int.parse(recommendedPlanId) - 1;
            if (index >= 0 && index < topPlans.length) {
              final plan = topPlans[index];
              result['recommended_plan'] = _planToApiResponse(plan);
            }
          } catch (e) {
            print('Recommended plan ID parsing error: $e');
          }
        }
        
        // Add alternative plans
        List<Map<String, dynamic>> alternativePlans = [];
        for (String planId in alternativePlanIds) {
          if (planId.isEmpty) {
            continue;
          }
          
          try {
            int index = int.parse(planId) - 1;
            if (index >= 0 && index < topPlans.length) {
              final plan = topPlans[index];
              alternativePlans.add(_planToApiResponse(plan));
            }
          } catch (e) {
            print('Alternative plan ID parsing error: $e');
          }
        }
        
        if (alternativePlans.isNotEmpty) {
          result['alternative_plans'] = alternativePlans;
        }
        
        return result;
      } else {
        throw Exception('JSON data not found');
      }
    } catch (e) {
      print('Recommendation parsing error: $e');
      return {
        'error': true,
        'message': 'Failed to parse recommendation: ${e.toString()}'
      };
    }
  }
  
  // Convert Plan object to API response format
  static Map<String, dynamic> _planToApiResponse(ESIMPlan plan) {
    // Calculate cost per GB
    double pricePerGB = plan.pricePerGB;
    
    // Basic plan information
    final Map<String, dynamic> response = {
      'id': plan.id,
      'provider': plan.provider,
      'provider_info': plan.providerInfo,
      'provider_image': plan.providerImage,
      'provider_slug': plan.providerSlug,
      'country': plan.country?.toLowerCase(),
      'plan_name': plan.name ?? plan.enName,
      'data_limit': plan.dataLimit > 999 ? 'Unlimited' : '${plan.dataLimit.toStringAsFixed(1)} GB',
      'validity_days': plan.validityDays,
      'price': '\$${plan.priceUSD.toStringAsFixed(2)}',
      'price_per_gb': pricePerGB,
      'is_certified': plan.isCertified,
      'popularity': plan.popularity,
    };
    
    // Price information
    response['price'] = '\$${plan.priceUSD.toStringAsFixed(2)}';
    response['price_per_gb'] = pricePerGB;
    
    // Promotion information
    if (plan.promoPrice != null) {
      response['promo_price'] = plan.promoPrice;
      response['discounted_price'] = plan.promoPrice != null ? '\$${plan.promoPrice!.toStringAsFixed(2)}' : null;
      
      if (plan.promoCode != null && plan.promoCode!.isNotEmpty) {
        response['promo_code'] = plan.promoCode;
      }
      
      if (plan.promoExpiry != null && plan.promoExpiry!.isNotEmpty) {
        response['promo_expiry'] = plan.promoExpiry;
      }
      
      if (plan.promoTitle != null && plan.promoTitle!.isNotEmpty) {
        response['promo_title'] = plan.promoTitle;
      }
    }
    
    // Features
    response['features'] = {
      'tethering': plan.tethering,
      'low_latency': plan.isLowLatency,
      'phone_number': plan.phoneNumber,
      'can_top_up': plan.canTopUp,
      'has_5g': plan.has5G,
      'has_ads': plan.hasAds,
      'subscription': plan.subscription,
      'ekYC': plan.eKYC,
      'internet_breakouts': plan.internetBreakouts,
    };
    
    // Promotion information
    response['promo_info'] = {
      'promo_title': plan.promoTitle,
      'promo_code': plan.promoCode,
      'promo_expiry': plan.promoExpiry,
      'promo_enabled': plan.promoEnabled,
    };
    
    // Provider information
    response['provider_info'] = plan.providerInfo;
    
    // Additional information
    response['additional_info'] = plan.additionalInfo;
    
    return response;
  }
  
  // Clean formatting characters from text
  static String _cleanFormattingChars(String text) {
    // Clean Markdown formatting characters
    String cleaned = text
      .replaceAll(RegExp(r'(\*\*|__)(.*?)\1'), r'\2') // Bold (**text**)
      .replaceAll(RegExp(r'(\*|_)(.*?)\1'), r'\2')    // Italic (*text*)
      .replaceAll(RegExp(r'^\s*[#]+\s*', multiLine: true), '')  // Headings (#, ##, ###)
      .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '') // List items (-, *, +)
      .replaceAll(RegExp(r'`{1,3}'), '');                      // Code blocks (`code`)
    
    // Clean plan numbers (e.g., "Plan 1:", "PLAN 2:", "Plan #3")
    cleaned = cleaned.replaceAll(RegExp(r'\b[Pp][Ll][Aa][Nn]\s+\d+[:\s]'), '');
    
    // Clean extra spaces and empty lines
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    return cleaned;
  }
  
  // Convert Plan data to Map
  static Map<String, dynamic> _planToMap(ESIMPlan plan) {
    return {
      'provider': plan.provider,
      'provider_slug': plan.providerSlug,
      'country': plan.country?.toLowerCase(),
      'id': plan.id,
      'name': plan.name ?? plan.enName ?? '',
      'plan_name': plan.name ?? plan.enName ?? '',
      'data_limit': '${plan.dataLimit.toString()} GB',
      'validity_days': plan.validityDays.toString(),
      'price': '\$${plan.priceUSD.toStringAsFixed(2)}',
      'promo_price': plan.promoPrice,
      'discounted_price': plan.promoPrice != null ? '\$${plan.promoPrice!.toStringAsFixed(2)}' : null,
      'price_per_gb': plan.pricePerGB,
      'price_per_day': plan.pricePerDay,
      'is_certified': plan.isCertified,
      'popularity': plan.popularity,
      'promo_code': plan.promoCode,
      'promo_expiry': plan.promoExpiry,
      'features': {
        'tethering': plan.tethering,
        'low_latency': plan.isLowLatency,
        'phone_number': plan.phoneNumber,
        'can_top_up': plan.canTopUp,
        'has_5g': plan.has5G,
        'has_ads': plan.hasAds,
        'subscription': plan.subscription,
        'ekYC': plan.eKYC,
        'internet_breakouts': plan.internetBreakouts,
      },
      'promo_info': {
        'promo_title': plan.promoTitle,
        'promo_code': plan.promoCode,
        'promo_expiry': plan.promoExpiry,
        'promo_enabled': plan.promoEnabled,
      },
      'provider_info': plan.providerInfo,
      'provider_image': plan.providerImage,
      'additional_info': plan.additionalInfo,
      'activation_info': plan.activationInfo,
    };
  }
} 