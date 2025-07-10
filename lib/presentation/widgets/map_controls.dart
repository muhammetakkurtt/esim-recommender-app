import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

import '../utils/map_styles.dart';

/// UI components for map controls
class MapControls {
  /// Create map control button
  static Widget buildControlButton({
    required IconData icon, 
    required VoidCallback onTap, 
    EdgeInsetsGeometry? margin,
    double padding = 6.0,
    String? tooltip,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: MapStyles.secondaryColor,
        shape: BoxShape.circle,
        boxShadow: [MapStyles.defaultShadow()],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Tooltip(
          message: tooltip ?? '',
          child: InkWell(
            onTap: () {
              onTap();
              HapticFeedback.selectionClick();
            },
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Icon(
                icon, 
                color: MapStyles.primaryColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Create rounded map control button
  static Widget buildRoundedControlButton({
    required IconData icon, 
    required VoidCallback onTap, 
    String? tooltip,
    double padding = 8.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: MapStyles.secondaryColor,
        borderRadius: BorderRadius.circular(MapStyles.cornerRadiusSmall),
        boxShadow: [MapStyles.defaultShadow(opacity: 0.15)],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(MapStyles.cornerRadiusSmall),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: Icon(icon, color: MapStyles.primaryColor),
          onPressed: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          tooltip: tooltip,
        ),
      ),
    );
  }
  
  /// Map zoom control
  static void zoomMap(AnimatedMapController mapController, double zoomChange) {
    mapController.mapController.move(
      mapController.mapController.camera.center, 
      mapController.mapController.camera.zoom + zoomChange
    );
  }
  
  /// Reset map rotation
  static void resetRotation(AnimatedMapController mapController) {
    mapController.mapController.rotate(0);
    HapticFeedback.mediumImpact();
  }
  
  /// Go to specific location
  static void goToLocation(
    AnimatedMapController mapController, 
    LatLng position,
    {double zoom = 3.0}
  ) {
    mapController.animateTo(
      dest: position,
      zoom: zoom,
    );
    HapticFeedback.mediumImpact();
  }
  
  /// Create a group containing zoom and control buttons
  static Widget buildControlsGroup(
    AnimatedMapController mapController,
    {LatLng? selectedPosition}
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Go to current location button
        if (selectedPosition != null)
          buildControlButton(
            icon: Icons.my_location,
            onTap: () => goToLocation(mapController, selectedPosition),
            margin: const EdgeInsets.only(bottom: 12),
            padding: 8.0,
          ),
        
        // Zoom in
        buildControlButton(
          icon: Icons.add,
          onTap: () => zoomMap(mapController, 0.5),
          margin: const EdgeInsets.only(bottom: 8),
        ),
        
        // Zoom out
        buildControlButton(
          icon: Icons.remove,
          onTap: () => zoomMap(mapController, -0.5),
          margin: const EdgeInsets.only(bottom: 8),
        ),
        
        // Orient to north button
        buildControlButton(
          icon: Icons.navigation,
          onTap: () => resetRotation(mapController),
          tooltip: 'Orient to North',
        ),
      ],
    );
  }
} 