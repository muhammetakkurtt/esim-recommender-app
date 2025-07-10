import 'package:flutter/material.dart';

/// Style definitions for the map and related UI components
class MapStyles {
  // Colors
  static const Color primaryColor = Color(0xFF5D69E3);
  static const Color secondaryColor = Colors.white;
  static Color primaryColorLight = primaryColor.withOpacity(0.1);
  static Color primaryColorMedium = primaryColor.withOpacity(0.5);
  
  // Animation durations
  static const Duration defaultAnimDuration = Duration(milliseconds: 300);
  static const Duration mapAnimDuration = Duration(milliseconds: 500);
  
  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve entryCurve = Curves.easeOutBack;
  static const Curve exitCurve = Curves.easeInBack;
  
  // Corner radii
  static const double cornerRadiusLarge = 24.0;
  static const double cornerRadiusMedium = 16.0;
  static const double cornerRadiusSmall = 12.0;
  
  // Shadows
  static BoxShadow defaultShadow({double opacity = 0.1, double blurRadius = 8.0}) {
    return BoxShadow(
      color: Colors.black.withOpacity(opacity),
      blurRadius: blurRadius,
      spreadRadius: 1,
      offset: const Offset(0, 2),
    );
  }
  
  static BoxShadow primaryShadow({double opacity = 0.2, double blurRadius = 10.0}) {
    return BoxShadow(
      color: primaryColor.withOpacity(opacity),
      blurRadius: blurRadius,
      offset: const Offset(0, 3),
    );
  }
  
  // Gradient styles
  static LinearGradient primaryGradient() {
    return LinearGradient(
      colors: [primaryColor, Colors.purple.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  static LinearGradient lightGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, Colors.grey.shade100],
    );
  }
  
  // Heatmap color palettes
  static List<Color> heatmapColors = [
    Colors.blue.withOpacity(0.2),
    Colors.blue.withOpacity(0.5),
    Colors.yellow.withOpacity(0.7),
    Colors.red.withOpacity(0.8),
  ];
  
  // Map style URLs
  static List<String> mapStyleUrls = [
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OpenStreetMap
    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', // Carto Light
    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', // Carto Dark
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', // Esri Satellite
  ];
  
  // Default map options
  static MapOptionsConfig defaultMapOptions = MapOptionsConfig(
    initialZoom: 1.8,
    minZoom: 1.5,
    maxZoom: 5.0,
  );
  
  // Fullscreen map options
  static MapOptionsConfig fullScreenMapOptions = MapOptionsConfig(
    initialZoom: 1.8,
    minZoom: 1.0,
    maxZoom: 18.0,
  );
}

/// Configuration class for map options
class MapOptionsConfig {
  final double initialZoom;
  final double minZoom;
  final double maxZoom;
  
  const MapOptionsConfig({
    required this.initialZoom,
    required this.minZoom,
    required this.maxZoom,
  });
} 