class ESIMPlan {
  final String id;
  final String provider;
  final String providerInfo;
  final String? providerImage;
  final String? providerSlug;
  final bool isCertified;
  final int popularity;
  
  // Plan information
  final String? name;
  final String? enName;
  final double dataLimit;
  final int validityDays;
  final double priceUSD;
  final double? promoPrice;
  final Map<String, dynamic>? prices;
  final Map<String, dynamic>? promoPrices;
  
  // Features
  final bool subscription;
  final bool phoneNumber;
  final bool canTopUp;
  final bool tethering;
  final bool isLowLatency;
  final bool has5G;
  final bool eKYC;
  final bool promoEnabled;
  final bool hasAds;
  final bool payAsYouGo;
  final bool newUserOnly;
  final List<String> internetBreakouts;
  final List<String> networkTypes;
  
  // Promotion information
  final String? promoTitle;
  final String? promoCode;
  final dynamic promoDiscount;
  final String? promoInfo;
  final String? promoExpiry;
  final String? promoExpiryTimeZone;
  final bool promoPercentage;
  
  // Other information
  final String? priceInfo;
  final String? capacityInfo;
  final String? validityInfo;
  final String? additionalInfo;
  final String? activationInfo;
  final String? country;
  final String? giveawayTitle;
  final String? giveawayLinkTitle;
  final String? giveawayInfo;
  final String? giveawayLink;
  final String? dataCapPer;
  final String? speedLimit;
  final String? reducedSpeed;
  final bool possibleThrottling;

  ESIMPlan({
    required this.id,
    required this.provider,
    required this.providerInfo,
    this.providerImage,
    this.providerSlug,
    required this.isCertified,
    required this.popularity,
    this.name,
    this.enName,
    required this.dataLimit,
    required this.validityDays,
    required this.priceUSD,
    this.promoPrice,
    this.prices,
    this.promoPrices,
    required this.subscription,
    required this.phoneNumber,
    required this.canTopUp,
    required this.tethering,
    required this.isLowLatency,
    required this.has5G,
    required this.eKYC,
    required this.promoEnabled,
    required this.hasAds,
    required this.payAsYouGo,
    required this.newUserOnly,
    required this.internetBreakouts,
    required this.networkTypes,
    this.promoTitle,
    this.promoCode,
    this.promoDiscount,
    this.promoInfo,
    this.promoExpiry,
    this.promoExpiryTimeZone,
    required this.promoPercentage,
    this.priceInfo,
    this.capacityInfo,
    this.validityInfo,
    this.additionalInfo,
    this.activationInfo,
    this.country,
    this.giveawayTitle,
    this.giveawayLinkTitle,
    this.giveawayInfo,
    this.giveawayLink,
    this.dataCapPer,
    this.speedLimit,
    this.reducedSpeed,
    required this.possibleThrottling,
  });

  factory ESIMPlan.fromJson(Map<String, dynamic> json) {
    // Extract data amount correctly
    double dataLimit = 0;
    if (json['capacity'] != null) {
      final String capacity = json['capacity'].toString();
      final RegExp regex = RegExp(r'(\d+(?:\.\d+)?)');
      final match = regex.firstMatch(capacity);
      if (match != null) {
        dataLimit = double.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }
    
    // Extract validity period
    int validityDays = json['period'] ?? 0;
    
    // Price information
    double priceUSD = json['usdPrice']?.toDouble() ?? 0;
    double? promoPrice = json['usdPromoPrice']?.toDouble();
    
    // Other data
    final String id = (json['_id'] ?? '').toString();
    final String provider = (json['provider'] ?? 'Unknown').toString();
    final String providerInfo = (json['provider_info'] ?? '').toString();
    final String? providerImage = json['provider_image']?.toString();
    final String? providerSlug = json['provider_slug']?.toString();
    final bool isCertified = json['provider_certified'] ?? false;
    final int popularity = _parseInt(json['provider_popularity'] ?? 0);
    
    // Plan information
    final String? name = json['name']?.toString();
    final String? enName = json['enName']?.toString();
    
    // Features - nullable boolean values
    final bool subscription = json['subscription'] ?? false;
    final bool phoneNumber = json['phone_number'] ?? false;
    final bool canTopUp = json['canTopUp'] ?? false;
    final bool tethering = json['tethering'] ?? false;
    final bool isLowLatency = json['isLowLatency'] ?? false;
    final bool has5G = json['has5G'] ?? false;
    final bool eKYC = json['eKYC'] ?? false;
    final bool promoEnabled = json['promoEnabled'] ?? false;
    final bool hasAds = json['hasAds'] ?? false;
    final bool payAsYouGo = json['payAsYouGo'] ?? false;
    final bool newUserOnly = json['newUserOnly'] ?? false;
    final bool possibleThrottling = json['possibleThrottling'] ?? false;
    
    // Promotion information
    final String? promoTitle = json['provider_promo_title']?.toString();
    final String? promoCode = json['provider_promo_code']?.toString();
    final dynamic promoDiscount = json['provider_promo_discount'];
    final String? promoInfo = json['provider_promo_info']?.toString();
    final String? promoExpiry = json['provider_promo_expiry']?.toString();
    final String? promoExpiryTimeZone = json['provider_promo_expiry_time_zone']?.toString();
    final bool promoPercentage = json['provider_promo_percentage'] ?? false;
    
    // Internet breakouts and network types
    List<String> internetBreakouts = [];
    if (json['internet_breakouts'] != null && json['internet_breakouts'] is List) {
      internetBreakouts = (json['internet_breakouts'] as List).map((e) => e.toString()).toList();
    }
    
    List<String> networkTypes = [];
    if (json['networkTypes'] != null && json['networkTypes'] is List) {
      networkTypes = (json['networkTypes'] as List).map((e) => e.toString()).toList();
    }
    
    // Other information
    final String? priceInfo = json['price_info']?.toString();
    final String? capacityInfo = json['capacity_info']?.toString();
    final String? validityInfo = json['validity_info']?.toString();
    final String? additionalInfo = json['additionalInfo']?.toString();
    final String? activationInfo = json['activationInfo']?.toString();
    final String? country = json['country']?.toString();
    final String? giveawayTitle = json['provider_giveaway_title']?.toString();
    final String? giveawayLinkTitle = json['provider_giveaway_link_title']?.toString();
    final String? giveawayInfo = json['provider_giveaway_info']?.toString();
    final String? giveawayLink = json['provider_giveaway_link']?.toString();
    final String? dataCapPer = json['dataCapPer']?.toString();
    final String? speedLimit = json['speedLimit']?.toString();
    final String? reducedSpeed = json['reducedSpeed']?.toString();
    
    // Safely convert price and promo price fields
    Map<String, dynamic>? prices;
    if (json['prices'] != null && json['prices'] is Map) {
      prices = Map<String, dynamic>.from(json['prices']);
    }
    
    Map<String, dynamic>? promoPrices;
    if (json['promoPrices'] != null && json['promoPrices'] is Map) {
      promoPrices = Map<String, dynamic>.from(json['promoPrices']);
    }
    
    return ESIMPlan(
      id: id,
      provider: provider,
      providerInfo: providerInfo,
      providerImage: providerImage,
      providerSlug: providerSlug,
      isCertified: isCertified,
      popularity: popularity,
      name: name,
      enName: enName,
      dataLimit: dataLimit,
      validityDays: validityDays,
      priceUSD: priceUSD,
      promoPrice: promoPrice,
      prices: prices,
      promoPrices: promoPrices,
      subscription: subscription,
      phoneNumber: phoneNumber,
      canTopUp: canTopUp,
      tethering: tethering,
      isLowLatency: isLowLatency,
      has5G: has5G,
      eKYC: eKYC,
      promoEnabled: promoEnabled,
      hasAds: hasAds,
      payAsYouGo: payAsYouGo,
      newUserOnly: newUserOnly,
      internetBreakouts: internetBreakouts,
      networkTypes: networkTypes,
      promoTitle: promoTitle,
      promoCode: promoCode,
      promoDiscount: promoDiscount,
      promoInfo: promoInfo,
      promoExpiry: promoExpiry,
      promoExpiryTimeZone: promoExpiryTimeZone,
      promoPercentage: promoPercentage,
      priceInfo: priceInfo,
      capacityInfo: capacityInfo,
      validityInfo: validityInfo,
      additionalInfo: additionalInfo,
      activationInfo: activationInfo,
      country: country,
      giveawayTitle: giveawayTitle,
      giveawayLinkTitle: giveawayLinkTitle,
      giveawayInfo: giveawayInfo,
      giveawayLink: giveawayLink,
      dataCapPer: dataCapPer,
      speedLimit: speedLimit,
      reducedSpeed: reducedSpeed,
      possibleThrottling: possibleThrottling,
    );
  }
  
  // Helper methods
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final String cleanedStr = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanedStr) ?? 0;
    }
    return 0;
  }
  
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final String cleanedStr = value.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(cleanedStr) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'provider_info': providerInfo,
      'provider_image': providerImage,
      'provider_slug': providerSlug,
      'provider_certified': isCertified,
      'provider_popularity': popularity,
      'name': name,
      'enName': enName,
      'capacity': '${dataLimit.toString()} GB',
      'period': validityDays,
      'usdPrice': priceUSD,
      'usdPromoPrice': promoPrice,
      'prices': prices,
      'promoPrices': promoPrices,
      'subscription': subscription,
      'phone_number': phoneNumber,
      'canTopUp': canTopUp,
      'tethering': tethering,
      'isLowLatency': isLowLatency,
      'has5G': has5G,
      'eKYC': eKYC,
      'promoEnabled': promoEnabled,
      'hasAds': hasAds,
      'payAsYouGo': payAsYouGo,
      'newUserOnly': newUserOnly,
      'internetBreakouts': internetBreakouts,
      'networkTypes': networkTypes,
      'provider_promo_title': promoTitle,
      'provider_promo_code': promoCode,
      'provider_promo_discount': promoDiscount,
      'provider_promo_info': promoInfo,
      'provider_promo_expiry': promoExpiry,
      'provider_promo_expiry_time_zone': promoExpiryTimeZone,
      'provider_promo_percentage': promoPercentage,
      'price_info': priceInfo,
      'capacity_info': capacityInfo,
      'validity_info': validityInfo,
      'additionalInfo': additionalInfo,
      'activationInfo': activationInfo,
      'country': country,
      'provider_giveaway_title': giveawayTitle,
      'provider_giveaway_link_title': giveawayLinkTitle,
      'provider_giveaway_info': giveawayInfo,
      'provider_giveaway_link': giveawayLink,
      'dataCapPer': dataCapPer,
      'speedLimit': speedLimit,
      'reducedSpeed': reducedSpeed,
      'possibleThrottling': possibleThrottling,
    };
  }

  // Currency symbols
  String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'AUD': return 'A\$';
      case 'CAD': return 'C\$';
      case 'NZD': return 'NZ\$';
      case 'SGD': return 'S\$';
      case 'KRW': return '₩';
      default: return currency;
    }
  }

  // Price information with selected currency
  String getPriceForCurrency(String currencyCode) {
    if (prices != null && prices!.containsKey(currencyCode)) {
      final price = prices![currencyCode];
      return '${getCurrencySymbol(currencyCode)}${price.toString()}';
    }
    return '${getCurrencySymbol('USD')}${priceUSD.toString()}';
  }
  
  // Discounted price information with selected currency
  String? getPromoPriceForCurrency(String currencyCode) {
    if (promoPrices != null && promoPrices!.containsKey(currencyCode)) {
      final promoPrice = promoPrices![currencyCode];
      return '${getCurrencySymbol(currencyCode)}${promoPrice.toString()}';
    } else if (promoPrice != null) {
      return '${getCurrencySymbol('USD')}${promoPrice.toString()}';
    }
    return null;
  }

  // Calculate cost per GB
  double get pricePerGB {
    if (dataLimit <= 0) return 0;
    return (promoPrice ?? priceUSD) / dataLimit;
  }
  
  // Calculate cost per day
  double get pricePerDay {
    if (validityDays <= 0) return 0;
    return (promoPrice ?? priceUSD) / validityDays;
  }

  @override
  String toString() {
    final priceText = promoPrice != null 
        ? '\$${promoPrice!.toStringAsFixed(2)} (regular: \$${priceUSD.toStringAsFixed(2)})'
        : '\$${priceUSD.toStringAsFixed(2)}';
    
    final String planNameText = name ?? enName ?? 'Unknown Plan';
    
    return 'ESIMPlan{id: $id, provider: $provider, plan: $planNameText, dataLimit: $dataLimit GB, validityDays: $validityDays days, price: $priceText}';
  }
} 