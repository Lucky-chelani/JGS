import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationResult {
  final String pincode;
  final String city;
  final String state;
  final String fullAddress;

  const LocationResult({
    required this.pincode,
    required this.city,
    required this.state,
    required this.fullAddress,
  });
}

class LocationService {
  /// Requests permission, gets current coordinates, and resolves to a
  /// [LocationResult] with pincode, city and state.
  ///
  /// Throws a [String] error message if anything goes wrong.
  static Future<LocationResult> getCurrentLocation() async {
    // 1. Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled on your device. Please enable them in Settings.';
    }

    // 2. Check / request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission was denied. Please allow location access to auto-fill your address.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission is permanently denied. Please enable it in your device Settings.';
    }

    // 3. Get current position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    debugPrint('📍 Location: ${position.latitude}, ${position.longitude}');

    // 4. Reverse geocode — try postalpincode.in API first for India (accurate pincode)
    try {
      return await _resolveViaPostalpincodeApi(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      debugPrint('postalpincode API failed: $e, falling back to geocoding pkg');
    }

    // 5. Fallback to geocoding package
    return await _resolveViaGeocodingPackage(
      position.latitude,
      position.longitude,
    );
  }

  // ── India-specific: positionstack / nominatim for accurate pincode ─────────

  static Future<LocationResult> _resolveViaPostalpincodeApi(
    double lat,
    double lng,
  ) async {
    // Nominatim (OpenStreetMap) – free, no API key, respects attribution
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
    );

    final response = await http.get(
      uri,
      headers: {'Accept-Language': 'en', 'User-Agent': 'JGSApp/1.0'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw 'Nominatim returned ${response.statusCode}';
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>? ?? {};

    final pincode =
        (address['postcode'] as String? ?? '').replaceAll(' ', '').trim();
    final city = _extractCity(address);
    final state = address['state'] as String? ?? '';
    final displayName = data['display_name'] as String? ?? '';

    if (pincode.isEmpty && city.isEmpty) {
      throw 'Could not resolve address from coordinates';
    }

    return LocationResult(
      pincode: pincode,
      city: city,
      state: state,
      fullAddress: displayName,
    );
  }

  static String _extractCity(Map<String, dynamic> address) {
    // Nominatim uses different keys depending on the region
    return (address['city'] as String?) ??
        (address['town'] as String?) ??
        (address['municipality'] as String?) ??
        (address['village'] as String?) ??
        (address['county'] as String?) ??
        '';
  }

  // ── Fallback: geocoding Flutter package ───────────────────────────────────

  static Future<LocationResult> _resolveViaGeocodingPackage(
    double lat,
    double lng,
  ) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) {
      throw 'No address found for your location. Please enter manually.';
    }
    final p = placemarks.first;
    return LocationResult(
      pincode: p.postalCode ?? '',
      city: p.locality ?? p.subAdministrativeArea ?? '',
      state: p.administrativeArea ?? '',
      fullAddress: [
        p.name,
        p.subLocality,
        p.locality,
        p.administrativeArea,
        p.country,
      ].where((s) => s != null && s.isNotEmpty).join(', '),
    );
  }
}
