import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'features_list.dart';
import 'promo_code_section.dart';
import 'info_item.dart';

class RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;
  final bool isMainRecommendation;

  const RecommendationCard({
    Key? key,
    required this.recommendation,
    this.isMainRecommendation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Empty check
    if (recommendation.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text('Plan information not found'),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: EdgeInsets.symmetric(vertical: isMainRecommendation ? 8 : 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isMainRecommendation 
                ? const Color(0xFF5D69E3).withOpacity(0.2) 
                : Colors.black.withOpacity(0.1),
            blurRadius: isMainRecommendation ? 20 : 10,
            offset: const Offset(0, 8),
            spreadRadius: isMainRecommendation ? 1 : 0,
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isMainRecommendation 
              ? const BorderSide(color: Color(0xFF5D69E3), width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Divider(height: 40, thickness: 1),
              _buildDataSection(),
              const SizedBox(height: 25),
              _buildPriceSection(),
              _buildCostPerGBSection(),
              
              // Promo code
              if (recommendation['promo_code'] != null)
                PromoCodeSection(
                  promoCode: recommendation['promo_code'],
                  promoExpiry: recommendation['promo_expiry'],
                ),
              
              // Features
              if (recommendation['features'] != null)
                FeaturesList(features: recommendation['features']),
              
              // Buy button
              _buildBuyButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          if (isMainRecommendation) 
            const Icon(Icons.recommend, color: Colors.amber, size: 40),
          const SizedBox(height: 8),
          
          // Show provider image if available
          if (recommendation['provider_image'] != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recommendation['provider_image'],
                height: 50,
                width: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sim_card, color: Colors.grey),
                  ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          Text(
            recommendation['plan_name'] ?? recommendation['provider'] ?? 'Recommended Plan',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            recommendation['provider'] ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InfoItem(
          icon: Icons.data_usage, 
          label: 'Data', 
          value: recommendation['data_limit'] ?? '',
          iconColor: const Color(0xFF5D69E3),
        ),
        InfoItem(
          icon: Icons.calendar_today, 
          label: 'Validity', 
          value: '${recommendation['validity_days'] ?? ''} days',
          iconColor: const Color(0xFF5D69E3),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (recommendation['discounted_price'] != null) ...[
          InfoItem(
            icon: Icons.money_off, 
            label: 'Discounted Price', 
            value: recommendation['discounted_price'] ?? '',
            iconColor: Colors.green,
            valueColor: Colors.green,
          ),
          InfoItem(
            icon: Icons.attach_money, 
            label: 'Regular Price', 
            value: recommendation['price'] ?? '',
            iconColor: Colors.grey,
            valueStyle: const TextStyle(
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
        ] else
          InfoItem(
            icon: Icons.attach_money, 
            label: 'Price', 
            value: recommendation['price'] ?? '',
            iconColor: const Color(0xFF5D69E3),
          ),
      ],
    );
  }

  Widget _buildCostPerGBSection() {
    if (recommendation['price_per_gb'] == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: [
        const SizedBox(height: 25),
        Center(
          child: InfoItem(
            icon: Icons.data_thresholding, 
            label: 'Cost per GB', 
            value: '\$${(recommendation['price_per_gb'] as double).toStringAsFixed(2)}/GB',
            iconColor: const Color(0xFF5D69E3),
          ),
        ),
      ],
    );
  }

  Widget _buildBuyButton(BuildContext context) {
    // Extract country and provider_slug information
    final String? country = recommendation['country']?.toString().toLowerCase();
    final String? providerSlug = recommendation['provider_slug']?.toString().toLowerCase();
    
    // Don't show the button if required information is missing
    if (country == null || country.isEmpty || providerSlug == null || providerSlug.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Create purchase URL
    final String buyUrl = 'https://esimdb.com/$country/$providerSlug';
    
    return Column(
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text(
              'Buy Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: () => _launchBuyUrl(context, buyUrl),
          ),
        ),
      ],
    );
  }

  Future<void> _launchBuyUrl(BuildContext context, String buyUrl) async {
    final Uri url = Uri.parse(buyUrl);
    try {
      // (debugging)
      print('Opening URL: $buyUrl');
      
      if (await canLaunchUrl(url)) {
        final bool launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
        
        if (!launched) {
          throw Exception('Could not open URL: $buyUrl');
        }
      } else {
        throw Exception('Could not open URL (not supported): $buyUrl');
      }
    } catch (e) {
      // Inform the user in case of error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open purchase page: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 