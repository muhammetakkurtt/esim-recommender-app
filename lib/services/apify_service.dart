import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/esim_plan.dart';
import 'dart:math' as Math;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApifyService {
  // Apify API key
  static String get apiKey => dotenv.env['APIFY_API_KEY']!;
  
  // eSIMDB Country Scraper Actor ID
  static const String actorId = 'muhammetakkurtt~esimdb-country-scraper';
  
  // API URL
  static final String baseUrl = 'https://api.apify.com/v2/acts/$actorId/run-sync-get-dataset-items';
  
  // OpenAPI schema URL
  static const String openApiUrl = 'https://api.apify.com/v2/acts/$actorId/builds/default/openapi.json';
  
  // List of supported countries
  static Map<String, String> supportedCountries = {};
  
  // Get supported countries by fetching OpenAPI schema
  static Future<Map<String, String>> fetchSupportedCountries() async {
    if (supportedCountries.isNotEmpty) {
      return supportedCountries; // Use cache if already loaded
    }
    
    try {
      print('Fetching OpenAPI schema...');
      final response = await http.get(Uri.parse(openApiUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> schema = json.decode(response.body);
        
        // Get country property enum values
        final List<dynamic> countryEnum = schema['components']['schemas']['inputSchema']
            ['properties']['country']['enum'];
        
        // Create map by formatting country names
        supportedCountries = _formatCountryNames(countryEnum.cast<String>());
        print('Found ${supportedCountries.length} supported countries');
        return supportedCountries;
      } else {
        print('Failed to get OpenAPI schema: ${response.statusCode}');
        return _getDefaultCountries(); // Return default list in case of error
      }
    } catch (e) {
      print('Error fetching OpenAPI schema: $e');
      return _getDefaultCountries(); // Return default list in case of error
    }
  }
  
  // Convert country code list to user-friendly names
  static Map<String, String> _formatCountryNames(List<String> countryCodes) {
    final Map<String, String> formattedMap = {};
    
    for (final code in countryCodes) {
      String displayName = code;
      
      // Convert from code format to user-friendly name
      displayName = displayName.replaceAll('-', ' '); // replace hyphen with space
      displayName = displayName.split(' ').map((word) => 
        word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}').join(' '); // Capitalize first letter of each word
      
      // Special cases
      if (code == 'uk') displayName = 'United Kingdom';
      if (code == 'usa') displayName = 'United States of America';
      if (code == 'uae') displayName = 'United Arab Emirates';
      
      formattedMap[displayName] = code;
    }
    
    // Map.fromEntries and sorted can be used for alphabetical sorting
    final sortedEntries = formattedMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return Map.fromEntries(sortedEntries);
  }
  
  // Default country list to use if API schema cannot be retrieved
  static Map<String, String> _getDefaultCountries() {
    return {
      'France': 'france',
      'Spain': 'spain',
      'Italy': 'italy',
      'United Kingdom': 'uk',
      'Germany': 'germany',
      'Turkey': 'turkey',
      'USA': 'usa',
      'Japan': 'japan',
      'Thailand': 'thailand',
      'China': 'china'
    };
  }
  
  // Fetch eSIM plans from Apify
  static Future<List<ESIMPlan>> fetchESIMPlans(String country) async {
    try {
      // Make sure the country parameter is valid
      if (country.isEmpty) {
        throw Exception('Country code not specified');
      }
      
      print('Sending Apify API request: $country');
      final response = await http.post(
        Uri.parse('$baseUrl?token=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'country': country,
          'limit': 0,
        }),
      );

      // Treat HTTP 2xx codes as successful responses
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        print('Apify API response successful: found ${jsonData.length} plans');
        return jsonData.map((planJson) => ESIMPlan.fromJson(planJson)).toList();
      } else {
        print('Apify API did not respond: ${response.statusCode} - ${response.body}');
        throw Exception('Apify API did not respond: ${response.statusCode}');
      }
    } catch (e) {
      print('Apify API error: $e');
      // Return empty list in case of error
      return [];
    }
  }

  // Filter eSIM plans according to user criteria
  static List<ESIMPlan> filterPlans({
    required List<ESIMPlan> plans,
    required int tripDuration,
    required double dataNeeded,
    required double budget,
  }) {
    // First stage: Basic filtering (definite criteria)
    List<ESIMPlan> basicFilteredPlans = plans.where((plan) {
      // Basic criteria (must be met exactly)
      bool meetsBasicCriteria = 
        plan.validityDays >= tripDuration &&  // Sufficient validity period
        plan.dataLimit >= dataNeeded &&       // Sufficient data package
        (plan.promoPrice ?? plan.priceUSD) <= budget && // Within budget
        !plan.hasAds;  // Plans without ads
        
      return meetsBasicCriteria;
    }).toList();
    
    // Print number of plans remaining after filtering
    print('Found ${basicFilteredPlans.length} plans meeting basic criteria (${tripDuration} days, ${dataNeeded} GB, \$${budget})');
    
    // Return empty list if no results
    if (basicFilteredPlans.isEmpty) {
      return [];
    }
    
    // Second stage: Score and sort plans
    final scoredPlans = basicFilteredPlans.map((plan) {
      // Scoring criteria and weights
      double score = 0;
      
      // 1. Price-performance ratio (value per GB) - high importance
      double pricePerGB = plan.pricePerGB;
      double normalizedPricePerGB = 0;
      
      // Find GB per price for all plans
      double minPricePerGB = double.infinity;
      double maxPricePerGB = 0;
      
      // Scan all to find min and max values
      for (var p in basicFilteredPlans) {
        if (p.pricePerGB < minPricePerGB) minPricePerGB = p.pricePerGB;
        if (p.pricePerGB > maxPricePerGB) maxPricePerGB = p.pricePerGB;
      }
      
      // Normalize PricePerGB value between 0-1 (lower is better)
      if (maxPricePerGB > minPricePerGB) {
        normalizedPricePerGB = 1 - ((pricePerGB - minPricePerGB) / (maxPricePerGB - minPricePerGB));
      } else {
        normalizedPricePerGB = 1; // All values are the same
      }
      
      // Price-performance score (0-50 range)
      double valueScore = normalizedPricePerGB * 50;
      
      // 2. Data package excess (how much more than needed?) - medium importance
      double dataBonus = 0;
      double excessData = plan.dataLimit - dataNeeded;
      // If data package is at least 10% more than needed, max 10 points
      if (excessData > 0) {
        double excessRatio = excessData / dataNeeded;
        if (excessRatio <= 0.5) { // Perfect range: 0%-50% excess
          dataBonus = 10 * (1 - excessRatio/0.5); // When between 0-0.5, score 10-0 points
        } else {
          dataBonus = 0; // No points when over 50% (too much unnecessary data)
        }
      }
      
      // 3. Validity period excess - medium importance
      double validityBonus = 0;
      int excessValidity = plan.validityDays - tripDuration;
      
      // Excess validity period is good, but too much is less advantageous
      if (excessValidity > 0) {
        int idealExcess = 7; // Ideally one week excess
        double excessRatio = excessValidity / idealExcess;
        if (excessRatio <= 1) {
          validityBonus = 10 * excessRatio; // 0-10 points for 0-7 days excess
        } else if (excessRatio <= 2) {
          validityBonus = 10; // 10 points for 7-14 days excess
        } else {
          validityBonus = 10 * (3 - excessRatio); // Decreasing points for 14+ days (too much is unnecessary)
          if (validityBonus < 0) validityBonus = 0;
        }
      }
      
      // 4. Provider reliability - high importance
      double providerBonus = 0;
      if (plan.isCertified) {
        providerBonus += 15; // 15 points for certified provider
      }
      // Popularity score (0-10 range)
      providerBonus += (plan.popularity / 100) * 10; // Scale 0-100 to 0-10
      
      // 5. Features bonus - low importance
      double featuresBonus = 0;
      if (plan.tethering) featuresBonus += 3; // Tethering feature
      if (plan.isLowLatency) featuresBonus += 2; // Low latency
      if (plan.canTopUp) featuresBonus += 2;  // Can top up
      if (plan.has5G) featuresBonus += 3; // 5G support
      if (!plan.hasAds) featuresBonus += 2; // No ads
      
      // 6. Promotion/discount bonus - medium importance
      double promoBonus = 0;
      if (plan.promoPrice != null && plan.promoEnabled) {
        // Calculate discount rate
        double discount = (plan.priceUSD - plan.promoPrice!) / plan.priceUSD;
        promoBonus = discount * 15; // 15 points for up to 100% discount
      }
      
      // Calculate total score (out of 100)
      score = valueScore + dataBonus + validityBonus + providerBonus + featuresBonus + promoBonus;
      
      // Debug
      // print('Plan: ${plan.provider} - Score: $score (Value: $valueScore, Data: $dataBonus, Validity: $validityBonus, Provider: $providerBonus, Features: $featuresBonus, Promo: $promoBonus)');
      
      return {
        'plan': plan, 
        'score': score
      };
    }).toList();
    
    // Sort by score (descending order)
    scoredPlans.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    
    // Return highest-scored plans
    return scoredPlans.map((item) => item['plan'] as ESIMPlan).toList();
  }

  // Sort the best plans
  static List<ESIMPlan> getBestPlans(List<ESIMPlan> filteredPlans, int limit) {
    return filteredPlans.take(limit).toList();
  }
} 