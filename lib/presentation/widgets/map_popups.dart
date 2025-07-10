import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../utils/map_styles.dart';
import '../services/country_service.dart';

/// Components for map popups and visual elements
class MapPopups {
  /// Create marker popup
  static Widget buildMarkerPopup(String countryName, BuildContext context, [PopupController? popupController]) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MapStyles.cornerRadiusSmall)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MapStyles.cornerRadiusSmall),
          gradient: MapStyles.lightGradient(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              countryName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: MapStyles.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            // Popularity indicator
            _buildPopularityIndicator(countryName, context),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              icon: const Icon(Icons.check, size: 16),
              label: const Text("Select", style: TextStyle(fontSize: 12)),
              onPressed: () => _selectCountryFromPopup(countryName, context, popupController),
              style: OutlinedButton.styleFrom(
                foregroundColor: MapStyles.primaryColor,
                side: const BorderSide(color: MapStyles.primaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(100, 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Popularity indicator
  static Widget _buildPopularityIndicator(String countryName, BuildContext context) {
    final countryService = Provider.of<CountryService>(context, listen: false);
    final countryCode = countryService.countryNameToCode[countryName]?.toLowerCase();
    double popularity = 0.0;
    
    // Popular countries and popularity values
    final Map<String, double> popularCountries = {
      'uk': 0.9,     // United Kingdom
      'france': 0.8, // France
      'spain': 0.7,  // Spain
      'italy': 0.7,  // Italy
      'germany': 0.6,// Germany
      'turkey': 0.5, // Turkey
      'usa': 0.8,    // USA
      'japan': 0.6,  // Japan
      'thailand': 0.5, // Thailand
    };
    
    if (countryCode != null && popularCountries.containsKey(countryCode)) {
      popularity = popularCountries[countryCode]!;
    }
    
    final List<Widget> stars = [];
    final int fullStars = (popularity * 5).round();
    
    // Don't show if there's no popularity value
    if (fullStars == 0 && !popularCountries.containsKey(countryCode)) {
      return const SizedBox.shrink();
    }
    
    for (int i = 0; i < 5; i++) {
      stars.add(
        Icon(
          i < fullStars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 14,
        ),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
  
  /// Select country from popup
  static void _selectCountryFromPopup(String countryName, BuildContext context, [PopupController? popupController]) {
    // Select country
    final countryService = Provider.of<CountryService>(context, listen: false);
    countryService.selectCountry(countryName);
    
    // Close popup if controller exists
    if (popupController != null) {
      popupController.hideAllPopups();
    }
    
    // Haptic feedback
    HapticFeedback.selectionClick();
  }
  
  /// Country selection indicator
  static Widget buildCountrySelectionIndicator(CountryService countryService) {
    return AnimatedSwitcher(
      duration: MapStyles.defaultAnimDuration,
      switchInCurve: MapStyles.entryCurve,
      switchOutCurve: MapStyles.exitCurve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, -0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: countryService.selectedCountryName == null
          ? buildCountrySelectionHint()
          : buildSelectedCountryTag(countryService.selectedCountryName!),
    );
  }
  
  /// Country selection hint
  static Widget buildCountrySelectionHint() {
    return Container(
      key: const ValueKey<String>("hint"),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: MapStyles.secondaryColor,
        borderRadius: BorderRadius.circular(MapStyles.cornerRadiusSmall),
        boxShadow: [MapStyles.defaultShadow()],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: MapStyles.primaryColorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.touch_app, size: 14, color: MapStyles.primaryColor),
          ),
          const SizedBox(width: 8),
          const Text(
            "Tap to select a country",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: MapStyles.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Selected country tag
  static Widget buildSelectedCountryTag(String countryName) {
    return Container(
      key: const ValueKey<String>("selectedCountry"),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: MapStyles.primaryGradient(),
        borderRadius: BorderRadius.circular(MapStyles.cornerRadiusSmall),
        boxShadow: [MapStyles.primaryShadow()],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            countryName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Loading indicator
  static Widget buildLoadingOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(MapStyles.cornerRadiusLarge),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(MapStyles.cornerRadiusMedium),
                boxShadow: [MapStyles.defaultShadow()],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: MapStyles.primaryColor,
                      strokeWidth: 3,
                      backgroundColor: MapStyles.primaryColorLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading Countries...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MapStyles.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Create heatmap layer
  static Widget buildHeatmapLayer(CountryService countryService) {
    // Popular countries and popularity values
    final Map<String, double> popularCountries = {
      'uk': 0.9,     // United Kingdom
      'france': 0.8, // France
      'spain': 0.7,  // Spain
      'italy': 0.7,  // Italy
      'germany': 0.6,// Germany
      'turkey': 0.5, // Turkey
      'usa': 0.8,    // USA
      'japan': 0.6,  // Japan
      'thailand': 0.5, // Thailand
    };
    
    // Create points for heatmap
    final List<CircleMarker> heatPoints = [];
    
    popularCountries.forEach((code, popularity) {
      if (countryService.countryCoordinates.containsKey(code)) {
        final coordinates = countryService.countryCoordinates[code]!;
        
        // Determine color intensity based on popularity
        final colorIndex = (popularity * (MapStyles.heatmapColors.length - 1)).round();
        final color = MapStyles.heatmapColors[math.min(colorIndex, MapStyles.heatmapColors.length - 1)];
        
        // Add heat point
        heatPoints.add(
          CircleMarker(
            point: coordinates,
            radius: 20 + (popularity * 30), // Size based on popularity
            color: color,
            useRadiusInMeter: false,
          ),
        );
      }
    });
    
    return CircleLayer(circles: heatPoints);
  }
} 