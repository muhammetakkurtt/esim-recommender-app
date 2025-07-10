import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_countries/flutter_countries.dart' hide State;
import 'dart:math' show sin, cos, sqrt, atan2, pi;

import '../widgets/map_markers.dart';
import '../utils/map_styles.dart';
import '../utils/map_utils.dart';
import '../utils/map_models.dart';
import '../../services/apify_service.dart';

/// Service class that manages country data
class CountryService extends ChangeNotifier {
  // Country list
  Map<String, String> _countryMap = {};
  
  // Country name -> code and code -> country name mappings
  Map<String, String> _countryNameToCode = {};
  Map<String, String> _countryCodeToName = {};
  
  // Country coordinates database
  Map<String, LatLng> _countryCoordinates = {};
  
  // Selected country
  String? _selectedCountryCode;
  String? _selectedCountryName;
  LatLng? _selectedPosition;
  
  // Loading states
  bool _isLoadingCountries = true;
  bool _isLoadingCoordinates = false;
  
  // Country markers to display on the map
  List<Marker> _countryMarkers = [];
  
  // Getter methods
  Map<String, String> get countryMap => _countryMap;
  Map<String, String> get countryNameToCode => _countryNameToCode;
  Map<String, String> get countryCodeToName => _countryCodeToName;
  Map<String, LatLng> get countryCoordinates => _countryCoordinates;
  String? get selectedCountryCode => _selectedCountryCode;
  String? get selectedCountryName => _selectedCountryName;
  LatLng? get selectedPosition => _selectedPosition;
  bool get isLoadingCountries => _isLoadingCountries;
  bool get isLoadingCoordinates => _isLoadingCoordinates;
  List<Marker> get countryMarkers => _countryMarkers;
  
  // Create Map data model
  MapDataModel get mapDataModel => MapDataModel(
    countryNameToCode: _countryNameToCode,
    countryCodeToName: _countryCodeToName,
    countryCoordinates: _countryCoordinates,
    selectedCountryName: _selectedCountryName,
    selectedCountryCode: _selectedCountryCode,
    selectedPosition: _selectedPosition,
  );
  
  // Singleton instance
  static final CountryService _instance = CountryService._internal();
  
  // Factory constructor
  factory CountryService() {
    return _instance;
  }
  
  // Private constructor
  CountryService._internal();
  
  // Initialize the service
  Future<void> initialize() async {
    if (!_isLoadingCountries) return; // Don't load again if already loaded
    await loadCountries();
  }
  
  // Select country action
  void selectCountry(String? countryName) {
    if (countryName == null) return;
    
    final countryCode = _countryNameToCode[countryName];
    if (countryCode == null) return;
    
    _selectedCountryName = countryName;
    _selectedCountryCode = countryCode;
    
    // Show on map
    if (_countryCoordinates.containsKey(countryCode)) {
      _selectedPosition = _countryCoordinates[countryCode];
    }
    
    // Update map markers
    _updateMapMarkers();
    
    // Notify listeners
    notifyListeners();
  }
  
  // Select location from map
  void selectLocation(LatLng point) {
    // Find the nearest country
    String? closestCountryCode;
    double minDistance = double.infinity;
    
    _countryCoordinates.forEach((code, coordinates) {
      // Only evaluate country codes present in _countryMap
      if (_countryCodeToName.containsKey(code)) {
        final distance = MapUtils.calculateDistance(point, coordinates);
        if (distance < minDistance) {
          minDistance = distance;
          closestCountryCode = code;
        }
      }
    });
    
    // Select if a close country is found and the distance is reasonable
    if (closestCountryCode != null && minDistance < 10) { // Adjust threshold as needed (e.g., 500 km)
      final countryName = _countryCodeToName[closestCountryCode];
      if (countryName != null) {
        _selectedCountryName = countryName;
        _selectedCountryCode = closestCountryCode;
        _selectedPosition = _countryCoordinates[closestCountryCode];
        
        // Update map markers
        _updateMapMarkers();
        
        // Notify listeners
        notifyListeners();
      }
    }
  }
  
  // Calculate distance between two locations in kilometers
  double _calculateDistance(LatLng point1, LatLng point2) {
    return MapUtils.calculateDistance(point1, point2);
  }
  
  // Load supported countries
  Future<void> loadCountries() async {
    _isLoadingCountries = true;
    notifyListeners();
    
    try {
      // Load country coordinates
      _countryCoordinates = await _loadCountryCoordinates();
      
      // Get countries from Apify service
      final countries = await ApifyService.fetchSupportedCountries();
      
      _countryMap = countries;
      
      // Create mapping maps
      _countryNameToCode.clear();
      _countryCodeToName.clear();
      
      countries.forEach((name, code) {
        _countryNameToCode[name] = code;
        _countryCodeToName[code] = name;
      });
      
      _isLoadingCountries = false;
      
      // Update map markers
      _updateMapMarkers();
      
      // Notify listeners
      notifyListeners();
      
    } catch (e) {
      print('Error loading country list: $e');
      
      // Use default list in case of error
      _countryMap = {
        'France': 'france',
        'United Kingdom': 'uk',
        'Germany': 'germany',
        'USA': 'usa',
        'Japan': 'japan',
        'Italy': 'italy',
        'Spain': 'spain',
        'Turkey': 'turkey',
      };
      
      // Create mapping maps
      _countryNameToCode.clear();
      _countryCodeToName.clear();
      
      _countryMap.forEach((name, code) {
        _countryNameToCode[name] = code;
        _countryCodeToName[code] = name;
      });
      
      _isLoadingCountries = false;
      
      // Load fallback coordinates if flutter_countries package fails
      _loadFallbackCoordinates();
      
      notifyListeners();
    }
  }
  
  // Get country coordinates from Flutter Countries package
  Future<Map<String, LatLng>> _loadCountryCoordinates() async {
    _isLoadingCoordinates = true;
    notifyListeners();
    
    final Map<String, LatLng> coordinates = {};
    
    try {
      // Load all countries
      final allCountries = await Countries.all;
      
      for (var country in allCountries) {
        // Find country by ISO2 code
        final iso2 = country.iso2?.toLowerCase();
        final iso3 = country.iso3?.toLowerCase();
        
        // If coordinates exist, add
        if (country.longitude != null && country.latitude != null && iso2 != null) {
          coordinates[iso2] = LatLng(
            double.parse(country.latitude!), 
            double.parse(country.longitude!)
          );
        }
        
        // Add ISO3 alternative as well
        if (country.longitude != null && country.latitude != null && iso3 != null) {
          coordinates[iso3] = LatLng(
            double.parse(country.latitude!), 
            double.parse(country.longitude!)
          );
        }
        
        // Also map by country name (slugified)
        if (country.longitude != null && country.latitude != null && country.name != null) {
          final normalizedName = country.name!.toLowerCase().replaceAll(' ', '-');
          coordinates[normalizedName] = LatLng(
            double.parse(country.latitude!), 
            double.parse(country.longitude!)
          );
        }
      }
      
      print("Number of loaded country coordinates: ${coordinates.length}");
    } catch (e) {
      print("Error loading country coordinates: $e");
    } finally {
      _isLoadingCoordinates = false;
      notifyListeners();
    }
    
    return coordinates;
  }
  
  // Load fallback coordinates
  void _loadFallbackCoordinates() {
    final fallbackCoordinates = {
      'france': LatLng(46.2276, 2.2137),
      'uk': LatLng(55.3781, -3.4360),
      'germany': LatLng(51.1657, 10.4515),
      'usa': LatLng(37.0902, -95.7129),
      'japan': LatLng(36.2048, 138.2529),
      'italy': LatLng(41.8719, 12.5674),
      'spain': LatLng(40.4637, -3.7492),
      'turkey': LatLng(38.9637, 35.2433),
      'thailand': LatLng(15.8700, 100.9925),
      'china': LatLng(35.8617, 104.1954),
    };
    
    _countryCoordinates = Map.from(fallbackCoordinates);
    _updateMapMarkers();
    notifyListeners();
  }
  
  // Create markers
  void _updateMapMarkers() {
    _countryMarkers = [];
    
    // Create marker only for countries existing in both countryMap and coordinates
    for (final code in _countryCodeToName.keys) {
      if (_countryCoordinates.containsKey(code)) {
        final name = _countryCodeToName[code]!;
        final coordinates = _countryCoordinates[code]!;
        
        final isSelected = name == _selectedCountryName;
        
        _countryMarkers.add(
          MapMarkers.createCountryMarker(
            point: coordinates,
            countryName: name,
            isSelected: isSelected,
            onTap: () => selectCountry(name),
          ),
        );
      }
    }
  }
} 