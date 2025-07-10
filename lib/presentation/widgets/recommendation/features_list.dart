import 'package:flutter/material.dart';

class FeaturesList extends StatelessWidget {
  final Map<String, dynamic> features;

  const FeaturesList({
    Key? key,
    required this.features,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> featuresList = _getFeaturesList();

    if (featuresList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
        const Text(
          'Features',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5D69E3)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: featuresList.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5D69E3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF5D69E3).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(feature['icon'], size: 16, color: const Color(0xFF5D69E3)),
                  const SizedBox(width: 6),
                  Text(
                    feature['name'],
                    style: const TextStyle(
                      color: Color(0xFF5D69E3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFeaturesList() {
    if (features is! Map<String, dynamic>) {
      return [];
    }

    final List<Map<String, dynamic>> featuresList = [];
    
    // Add features that are boolean true to the list
    if (features['tethering'] == true) {
      featuresList.add({'name': 'Tethering', 'icon': Icons.wifi_tethering});
    }
    if (features['low_latency'] == true) {
      featuresList.add({'name': 'Low Latency', 'icon': Icons.speed});
    }
    if (features['phone_number'] == true) {
      featuresList.add({'name': 'Phone Number', 'icon': Icons.phone});
    }
    if (features['can_top_up'] == true) {
      featuresList.add({'name': 'Can Top Up', 'icon': Icons.add_card});
    }
    if (features['has_5g'] == true) {
      featuresList.add({'name': '5G Support', 'icon': Icons.network_cell});
    }
    
    return featuresList;
  }
} 