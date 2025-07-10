import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../utils/map_styles.dart';
import '../services/country_service.dart';

/// Helper class for creating map markers
class MapMarkers {
  /// Create standard country marker
  static Marker createCountryMarker({
    required LatLng point,
    required String countryName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Marker(
      width: 40.0,
      height: 40.0,
      point: point,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          onTap();
          _vibrate(isLongPress: false);
        },
        child: AnimatedContainer(
          duration: MapStyles.defaultAnimDuration,
          decoration: BoxDecoration(
            color: isSelected ? MapStyles.primaryColor : MapStyles.secondaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? MapStyles.primaryColor.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            Icons.location_on,
            color: isSelected ? MapStyles.secondaryColor : MapStyles.primaryColor,
            size: 18,
          ),
        ),
      ),
    );
  }
  
  /// Create animated country marker
  static Marker createAnimatedMarker({
    required LatLng point,
    required String countryName,
    required bool isSelected,
    required VoidCallback onTap,
    required Animation<double> animation,
  }) {
    return Marker(
      width: 40.0 * (isSelected ? animation.value : 1.0),
      height: 40.0 * (isSelected ? animation.value : 1.0),
      point: point,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          onTap();
          _vibrate(isLongPress: false);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? MapStyles.primaryColor : MapStyles.secondaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? MapStyles.primaryColor.withOpacity(0.4 * animation.value)
                    : Colors.black.withOpacity(0.1),
                spreadRadius: isSelected ? 1.0 * animation.value : 1.0,
                blurRadius: isSelected ? 8.0 * animation.value : 5.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            Icons.location_on,
            color: isSelected ? MapStyles.secondaryColor : MapStyles.primaryColor,
            size: 18,
          ),
        ),
      ),
    );
  }
  
  /// Create marker cluster view
  static Widget buildClusterMarker(List<Marker> markers) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: MapStyles.primaryGradient(),
        boxShadow: [MapStyles.primaryShadow()],
      ),
      child: Center(
        child: Text(
          markers.length.toString(),
          style: const TextStyle(
            color: MapStyles.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  /// Find country name from marker
  static String getCountryNameFromMarker(Marker marker, CountryService service) {
    String countryName = "Country";
    for (final code in service.countryCodeToName.keys) {
      if (service.countryCoordinates.containsKey(code)) {
        final coordinates = service.countryCoordinates[code]!;
        if (marker.point.latitude == coordinates.latitude && 
            marker.point.longitude == coordinates.longitude) {
          countryName = service.countryCodeToName[code] ?? "Country";
          break;
        }
      }
    }
    return countryName;
  }
  
  /// Provide haptic feedback
  static void _vibrate({bool isLongPress = false}) {
    if (isLongPress) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }
} 