class RecommendationPlan {
  final String? id;
  final String? planName;
  final String? provider;
  final String? providerImage;
  final String? providerSlug;
  final String? country;
  final String? dataLimit;
  final String? validityDays;
  final String? price;
  final String? discountedPrice;
  final double? pricePerGb;
  final String? promoCode;
  final String? promoExpiry;
  final Map<String, dynamic>? features;

  RecommendationPlan({
    this.id,
    this.planName,
    this.provider,
    this.providerImage,
    this.providerSlug,
    this.country,
    this.dataLimit,
    this.validityDays,
    this.price,
    this.discountedPrice,
    this.pricePerGb,
    this.promoCode,
    this.promoExpiry,
    this.features,
  });

  factory RecommendationPlan.fromJson(Map<String, dynamic> json) {
    return RecommendationPlan(
      id: json['id'],
      planName: json['plan_name'],
      provider: json['provider'],
      providerImage: json['provider_image'],
      providerSlug: json['provider_slug'],
      country: json['country'],
      dataLimit: json['data_limit'],
      validityDays: json['validity_days']?.toString(),
      price: json['price'],
      discountedPrice: json['discounted_price'],
      pricePerGb: json['price_per_gb'],
      promoCode: json['promo_code'],
      promoExpiry: json['promo_expiry'],
      features: json['features'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'provider': provider,
      'provider_image': providerImage,
      'provider_slug': providerSlug,
      'country': country,
      'data_limit': dataLimit,
      'validity_days': validityDays,
      'price': price,
      'discounted_price': discountedPrice,
      'price_per_gb': pricePerGb,
      'promo_code': promoCode,
      'promo_expiry': promoExpiry,
      'features': features,
    };
  }

  bool get hasPromoCode => promoCode != null && promoCode!.isNotEmpty;
  bool get hasDiscount => discountedPrice != null && discountedPrice!.isNotEmpty;
  bool get hasFeatures => features != null && features!.isNotEmpty;
  bool get canBuy => country != null && providerSlug != null;
  
  String get buyUrl => 'https://esimdb.com/${country?.toLowerCase() ?? ''}/${providerSlug?.toLowerCase() ?? ''}';
  String get displayName => planName ?? provider ?? 'Recommended Plan';
}

class RecommendationResponse {
  final bool hasError;
  final String? errorMessage;
  final RecommendationPlan? recommendedPlan;
  final List<RecommendationPlan> alternativePlans;
  final String explanation;

  RecommendationResponse({
    this.hasError = false,
    this.errorMessage,
    this.recommendedPlan,
    this.alternativePlans = const [],
    this.explanation = '',
  });

  // Helper getters for UI
  bool get hasRecommendation => recommendedPlan != null;
  bool get hasAlternatives => alternativePlans.isNotEmpty;

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    // Error check
    if (json['error'] == true) {
      return RecommendationResponse(
        hasError: true,
        errorMessage: json['message'] ?? 'An error occurred.',
      );
    }

    // Main recommendation
    final RecommendationPlan? mainPlan = json['recommended_plan'] != null 
        ? RecommendationPlan.fromJson(json['recommended_plan'] as Map<String, dynamic>)
        : null;

    // Alternative recommendations
    final List<RecommendationPlan> altPlans = [];
    if (json['alternative_plans'] != null) {
      for (final plan in json['alternative_plans'] as List) {
        altPlans.add(RecommendationPlan.fromJson(plan as Map<String, dynamic>));
      }
    }

    return RecommendationResponse(
      recommendedPlan: mainPlan,
      alternativePlans: altPlans,
      explanation: json['explanation'] ?? 'No explanation found.',
    );
  }

  bool get isEmpty => !hasError && recommendedPlan == null && alternativePlans.isEmpty;
} 