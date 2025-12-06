import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'club_model.dart';

class SearchRequestModel {
  final String id;
  final String userId;
  final GeoPoint location;
  final DateTime dateTime;

  SearchRequestModel({
    required this.id,
    required this.userId,
    required this.location,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'dateTime': dateTime,
    'location': location,
  };

  factory SearchRequestModel.fromJson(Map<String, dynamic> json) =>
      SearchRequestModel(
        id: json['id'],
        userId: json['userId'],
        location: json['location'],
        dateTime: (json['dateTime'] as Timestamp).toDate(),
      );

  /// Find nearby clubs within a given radius (in kilometers)
  static List<ClubModel> findNearbyClubs(
    List<ClubModel> clubs,
    GeoPoint userLocation,
    {double radiusKm = 1500000.0}
  ) {
    final distance = Distance();
    final userLatLng = LatLng(userLocation.latitude, userLocation.longitude);

    final nearbyClubs = <ClubModel>[];

    for (final club in clubs) {
      final clubLatLng = LatLng(club.location.latitude, club.location.longitude);
      final distanceInMeters = distance(userLatLng, clubLatLng);
      final distanceInKm = distanceInMeters / 1000;

      if (distanceInKm <= radiusKm) {
        nearbyClubs.add(club);
      }
    }

    // Sort by distance
    nearbyClubs.sort((a, b) {
      final distanceA = distance(
        userLatLng,
        LatLng(a.location.latitude, a.location.longitude),
      );
      final distanceB = distance(
        userLatLng,
        LatLng(b.location.latitude, b.location.longitude),
      );
      return distanceA.compareTo(distanceB);
    });

    return nearbyClubs;
  }

  /// Get distance to a club in kilometers
  static double getDistanceToClub(GeoPoint userLocation, ClubModel club) {
    final distance = Distance();
    final userLatLng = LatLng(userLocation.latitude, userLocation.longitude);
    final clubLatLng = LatLng(club.location.latitude, club.location.longitude);
    final distanceInMeters = distance(userLatLng, clubLatLng);
    return distanceInMeters / 1000;
  }

  /// Sort clubs by distance without filtering
  static List<ClubModel> sortClubsByDistance(
    List<ClubModel> clubs,
    GeoPoint userLocation,
  ) {
    final distance = Distance();
    final userLatLng = LatLng(userLocation.latitude, userLocation.longitude);

    clubs.sort((a, b) {
      final distanceA = distance(
        userLatLng,
        LatLng(a.location.latitude, a.location.longitude),
      );
      final distanceB = distance(
        userLatLng,
        LatLng(b.location.latitude, b.location.longitude),
      );
      return distanceA.compareTo(distanceB);
    });

    return clubs;
  }
}
