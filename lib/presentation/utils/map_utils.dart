import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'dart:math' show sin, cos, sqrt, atan2, pi;

import 'map_styles.dart';
import 'map_models.dart';

/// Class containing helper methods for map functions
class MapUtils {
  // Constants
  static const Color primaryColor = Color(0xFF5D69E3);
  static const Color secondaryColor = Colors.white;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  /// Create country marker
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
          vibrate(isLongPress: false);
        },
        child: AnimatedContainer(
          duration: animationDuration,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : secondaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? primaryColor.withOpacity(0.4)
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
            color: isSelected ? secondaryColor : primaryColor,
            size: 18,
          ),
        ),
      ),
    );
  }
  
  /// Create animated marker
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
          vibrate(isLongPress: false);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : secondaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? primaryColor.withOpacity(0.4 * animation.value)
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
            color: isSelected ? secondaryColor : primaryColor,
            size: 18,
          ),
        ),
      ),
    );
  }
  
  /// Helper method providing haptic feedback
  static void vibrate({bool isLongPress = false}) {
    if (isLongPress) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }
  
  /// Animated transition to current or selected location
  static void animateToPosition({
    required AnimatedMapController controller, 
    required LatLng position,
    double zoom = 3.0,
  }) {
    controller.animateTo(
      dest: position,
      zoom: zoom,
    );
    vibrate();
  }
  
  /// Calculate distance between two locations in kilometers
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth radius (km)
    final double lat1 = point1.latitude * (pi / 180);
    final double lat2 = point2.latitude * (pi / 180);
    final double lon1 = point1.longitude * (pi / 180);
    final double lon2 = point2.longitude * (pi / 180);
    
    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
                     cos(lat1) * cos(lat2) * 
                     sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
} 