import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

import '../services/country_service.dart';
import '../utils/map_styles.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_markers.dart';
import '../widgets/map_popups.dart';

class FullScreenMap extends StatefulWidget {
  final MapController mapController;
  final Function() onBackPressed;
  final Function(LatLng location) onLocationSelected;
  
  const FullScreenMap({
    super.key,
    required this.mapController,
    required this.onBackPressed,
    required this.onLocationSelected,
  });

  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> with TickerProviderStateMixin {
  // Animated map controller
  late AnimatedMapController _animatedMapController;
  
  // Initial center position and zoom
  late LatLng _initialCenter;
  late double _currentZoom;
  
  // Animation controller
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Marker popup controller
  final PopupController _popupController = PopupController();
  
  // Current map style
  int _currentMapStyleIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Hide system UI (fullscreen)
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    
    // Get initial values from the small map
    _initialCenter = widget.mapController.camera.center;
    _currentZoom = widget.mapController.camera.zoom;
    
    // Initialize animated map controller
    _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: MapStyles.mapAnimDuration,
      curve: MapStyles.defaultCurve,
    );
    
    // Initialize animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    // Dispose our own controllers
    _animatedMapController.dispose();
    _pulseController.dispose();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }
  
  // Switch to the next map style
  void _toggleMapStyle() {
    setState(() {
      _currentMapStyleIndex = (_currentMapStyleIndex + 1) % MapStyles.mapStyleUrls.length;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Access CountryService
    final countryService = Provider.of<CountryService>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Map
          _buildMap(countryService),
          
          // Back button
          _buildBackButton(),
          
          // Map controls
          _buildMapControls(countryService),
          
          // Map style change button
          _buildMapStyleButton(),
          
          // If a country is selected, show selection button at the bottom
          if (countryService.selectedCountryName != null)
            _buildSelectionButton(countryService),
        ],
      ),
    );
  }
  
  // Main map widget
  Widget _buildMap(CountryService countryService) {
    return FlutterMap(
      mapController: _animatedMapController.mapController,
      options: MapOptions(
        initialCenter: _initialCenter,
        initialZoom: _currentZoom,
        minZoom: MapStyles.fullScreenMapOptions.minZoom,
        maxZoom: MapStyles.fullScreenMapOptions.maxZoom,
        onTap: (tapPosition, point) {
          // Notify the service about the location selection
          widget.onLocationSelected(point);
          
          // Animated transition to the selected location
          if (countryService.selectedPosition != null) {
            _animatedMapController.animateTo(
              dest: countryService.selectedPosition!,
              zoom: _currentZoom,
            );
          }
        },
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) {
            setState(() {
              _currentZoom = position.zoom!;
            });
          }
        },
        interactionOptions: const InteractionOptions(
          enableMultiFingerGestureRace: true,
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | 
                 InteractiveFlag.pinchMove | InteractiveFlag.doubleTapZoom | 
                 InteractiveFlag.rotate,
        ),
      ),
      children: [
        // Map layer
        TileLayer(
          urlTemplate: MapStyles.mapStyleUrls[_currentMapStyleIndex],
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
        
        // Heatmap
        MapPopups.buildHeatmapLayer(countryService),
        
        // Marker layer
        _buildMarkerLayer(countryService),
        
        // Map copyright information
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
  
  // Marker layer
  Widget _buildMarkerLayer(CountryService countryService) {
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        maxClusterRadius: 45,
        size: const Size(40, 40),
        padding: const EdgeInsets.all(50),
        markers: _buildAnimatedMarkers(countryService),
        polygonOptions: const PolygonOptions(
          borderColor: MapStyles.primaryColor,
          color: Colors.black12,
          borderStrokeWidth: 3,
        ),
        builder: (context, markers) => MapMarkers.buildClusterMarker(markers),
      ),
    );
  }
  
  // Create animated markers
  List<Marker> _buildAnimatedMarkers(CountryService countryService) {
    final List<Marker> markers = [];
    
    for (final code in countryService.countryCodeToName.keys) {
      if (countryService.countryCoordinates.containsKey(code)) {
        final name = countryService.countryCodeToName[code]!;
        final coordinates = countryService.countryCoordinates[code]!;
        
        final isSelected = name == countryService.selectedCountryName;
        
        markers.add(
          MapMarkers.createAnimatedMarker(
            point: coordinates,
            countryName: name,
            isSelected: isSelected,
            onTap: () {
              // Only select the country
              countryService.selectCountry(name);
              // Haptic feedback
              HapticFeedback.selectionClick();
            },
            animation: _pulseAnimation,
          ),
        );
      }
    }
    
    return markers;
  }
  
  // Back button
  Widget _buildBackButton() {
    return Positioned(
      top: 32,
      left: 16,
      child: MapControls.buildRoundedControlButton(
        icon: Icons.arrow_back,
        onTap: widget.onBackPressed,
        tooltip: 'Back',
      ),
    );
  }
  
  // Map controls
  Widget _buildMapControls(CountryService countryService) {
    return Positioned(
      left: 16,
      bottom: countryService.selectedCountryName != null ? 90 : 16,
      child: MapControls.buildControlsGroup(
        _animatedMapController,
        selectedPosition: countryService.selectedPosition,
      ),
    );
  }
  
  // Map style change button
  Widget _buildMapStyleButton() {
    return Positioned(
      top: 32,
      right: 16,
      child: MapControls.buildRoundedControlButton(
        icon: Icons.layers,
        onTap: _toggleMapStyle,
        tooltip: 'Map Style',
      ),
    );
  }
  
  // Selection button
  Widget _buildSelectionButton(CountryService countryService) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: MapStyles.primaryGradient(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                countryService.selectedCountryName ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (countryService.selectedPosition != null) {
                  // Haptic feedback
                  HapticFeedback.mediumImpact();
                  
                  // Confirm selection and go back
                  widget.onLocationSelected(countryService.selectedPosition!);
                  widget.onBackPressed();
                }
              },
              icon: const Icon(Icons.check, color: MapStyles.primaryColor),
              label: const Text(
                "Confirm Selection",
                style: TextStyle(color: MapStyles.primaryColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 