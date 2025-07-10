import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'dart:math' as math;

import '../screens/full_screen_map.dart';
import '../services/country_service.dart';
import '../utils/map_styles.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_markers.dart';
import '../widgets/map_popups.dart';

class MapLocationSelector extends StatefulWidget {
  final MapController? externalMapController;
  final Function(LatLng point)? onMapTap;
  final bool showFullScreenButton;

  const MapLocationSelector({
    super.key,
    this.externalMapController,
    this.onMapTap,
    this.showFullScreenButton = true,
  });

  @override
  State<MapLocationSelector> createState() => _MapLocationSelectorState();
}

class _MapLocationSelectorState extends State<MapLocationSelector> with TickerProviderStateMixin {
  // Animated map controller
  late final AnimatedMapController _animatedMapController;
  
  // Controller for marker clustering
  final PopupController _popupController = PopupController();
  
  // Popular countries (for heatmap)
  final Map<String, double> _popularCountries = {
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
  
  @override
  void initState() {
    super.initState();
    // Initialize animated map controller
    _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: MapStyles.mapAnimDuration,
      curve: MapStyles.defaultCurve,
      mapController: widget.externalMapController,
    );
  }
  
  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access to CountryService
    final countryService = Provider.of<CountryService>(context);
    
    return Container(
      height: 330,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MapStyles.cornerRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MapStyles.cornerRadiusLarge),
        child: Stack(
          children: [
            // Map component
            _buildMap(countryService),
            
            // Fullscreen button
            if (widget.showFullScreenButton)
              _buildFullscreenButton(context, countryService),
            
            // Show loading state
            if (countryService.isLoadingCoordinates)
              MapPopups.buildLoadingOverlay(),

            // Country selection indicator
            Positioned(
              top: 16,
              left: 16,
              child: MapPopups.buildCountrySelectionIndicator(countryService),
            ),
            
            // Zoom and location controls
            Positioned(
              left: 16,
              bottom: 16,
              child: MapControls.buildControlsGroup(
                _animatedMapController,
                selectedPosition: countryService.selectedPosition,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Map widget
  Widget _buildMap(CountryService countryService) {
    return FlutterMap(
      mapController: _animatedMapController.mapController,
      options: MapOptions(
        initialCenter: countryService.selectedPosition ?? const LatLng(30, 0),
        initialZoom: MapStyles.defaultMapOptions.initialZoom,
        minZoom: MapStyles.defaultMapOptions.minZoom,
        maxZoom: MapStyles.defaultMapOptions.maxZoom,
        onTap: (tapPosition, point) {
          if (widget.onMapTap != null) {
            widget.onMapTap!(point);
          } else {
            countryService.selectLocation(point);
            
            // Animated transition to selected location
            if (countryService.selectedPosition != null) {
              _animatedMapController.animateTo(
                dest: countryService.selectedPosition!,
                zoom: 3.0,
              );
            }
          }
        },
      ),
      children: [
        // Map layer
        TileLayer(
          urlTemplate: MapStyles.mapStyleUrls[0], // OpenStreetMap
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.esim_recommender',
          tileProvider: NetworkTileProvider(),
          maxZoom: 19,
          tileBuilder: (context, child, tile) {
            return AnimatedSwitcher(
              duration: MapStyles.defaultAnimDuration,
              child: child,
            );
          },
        ),
        
        // Heatmap layer
        MapPopups.buildHeatmapLayer(countryService),
        
        // Marker and popup layer
        _buildMarkerLayer(countryService),
        
        // Map attribution information
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
  
  // Marker clustering layer
  Widget _buildMarkerLayer(CountryService countryService) {
    return PopupScope(
      popupController: _popupController,
      child: MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          maxClusterRadius: 45,
          size: const Size(40, 40),
          padding: const EdgeInsets.all(50),
          markers: countryService.countryMarkers,
          polygonOptions: const PolygonOptions(
            borderColor: MapStyles.primaryColor,
            color: Colors.black12,
            borderStrokeWidth: 3,
          ),
          popupOptions: PopupOptions(
            popupController: _popupController,
            popupAnimation: const PopupAnimation.fade(
              duration: MapStyles.defaultAnimDuration, 
              curve: MapStyles.defaultCurve
            ),
            popupBuilder: (_, marker) => MapPopups.buildMarkerPopup(
              MapMarkers.getCountryNameFromMarker(marker, countryService),
              context,
              _popupController
            ),
          ),
          builder: (context, markers) => MapMarkers.buildClusterMarker(markers),
        ),
      ),
    );
  }
  
  // Fullscreen button
  Widget _buildFullscreenButton(BuildContext context, CountryService countryService) {
    return Positioned(
      top: 16,
      right: 16,
      child: MapControls.buildRoundedControlButton(
        icon: Icons.fullscreen, 
        onTap: () => _navigateToFullscreen(context, countryService),
        tooltip: 'Fullscreen Map',
      ),
    );
  }
  
  // Navigate to fullscreen map
  void _navigateToFullscreen(BuildContext context, CountryService countryService) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMap(
          mapController: _animatedMapController.mapController,
          onBackPressed: () => Navigator.pop(context),
          onLocationSelected: (location) {
            // Process selected point
            countryService.selectLocation(location);
          },
        ),
      ),
    );
  }
} 