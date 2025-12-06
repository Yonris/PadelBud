import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationState {
  final GeoPoint? currentLocation;
  final bool permissionGranted;
  final bool initialized;
  final String? error;

  const LocationState({
    this.currentLocation,
    this.permissionGranted = false,
    this.initialized = false,
    this.error,
  });

  LocationState copyWith({
    GeoPoint? position,
    bool? permissionGranted,
    bool? initialized,
    GeoPoint? currentLocation,
    String? error,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      initialized: initialized ?? this.initialized,
      error: error,
    );
  }
}

class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() {
    _loadLocation();
    return const LocationState();
  }

  static const _apiKey = 'AIzaSyDmf2XfUYq_JY9VWvHXN6GyPDG-nTzOCuc';

  Future<GeoPoint?> getGeoPointFromAddress(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data['status'] != 'OK' || data['results'].isEmpty) return null;

    final location = data['results'][0]['geometry']['location'];
    final lat = location['lat'] as double;
    final lng = location['lng'] as double;

    return GeoPoint(lat, lng);
  }

  Future<void> _loadLocation() async {
    try {
      bool granted = await _handlePermission();
      if (!granted) {
        state = state.copyWith(
          initialized: true,
          permissionGranted: false,
          error: "Location permission denied",
        );
        return;
      }

      final userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(
        currentLocation: GeoPoint(userLocation.latitude, userLocation.longitude),
        permissionGranted: true,
        initialized: true,
      );
    } catch (e) {
      state = state.copyWith(initialized: true, error: e.toString());
    }
  }

  Future<bool> _handlePermission() async {
    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  /// Public method to refresh location manually
  Future<void> updateLocation() async {
    await _loadLocation();
  }
}
