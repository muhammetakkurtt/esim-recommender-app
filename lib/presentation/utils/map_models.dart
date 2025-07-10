import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Map data model
class MapDataModel {
  final Map<String, String> countryNameToCode;
  final Map<String, String> countryCodeToName;
  final Map<String, LatLng> countryCoordinates;
  final String? selectedCountryName;
  final String? selectedCountryCode;
  final LatLng? selectedPosition;
  
  const MapDataModel({
    this.countryNameToCode = const {},
    this.countryCodeToName = const {},
    this.countryCoordinates = const {},
    this.selectedCountryName,
    this.selectedCountryCode,
    this.selectedPosition,
  });
  
  MapDataModel copyWith({
    Map<String, String>? countryNameToCode,
    Map<String, String>? countryCodeToName,
    Map<String, LatLng>? countryCoordinates,
    String? selectedCountryName,
    String? selectedCountryCode,
    LatLng? selectedPosition,
  }) {
    return MapDataModel(
      countryNameToCode: countryNameToCode ?? this.countryNameToCode,
      countryCodeToName: countryCodeToName ?? this.countryCodeToName,
      countryCoordinates: countryCoordinates ?? this.countryCoordinates,
      selectedCountryName: selectedCountryName ?? this.selectedCountryName,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      selectedPosition: selectedPosition ?? this.selectedPosition,
    );
  }
} 