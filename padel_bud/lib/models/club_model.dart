import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModel {
  String id;
  String name;
  final GeoPoint location;
  String address;
  final int numberOfCourts;
  final int gameDuration;
  String currency;
  final double price;
  final Map<String, Map<String, dynamic>> schedule;
  String? imageUrl;
  final String managerId;
  String? phone;
  ClubModel({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.numberOfCourts,
    required this.gameDuration,
    required this.currency,
    required this.price,
    required this.schedule,
    required this.managerId,
    this.imageUrl,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'location': location,
    'address': address,
    'numberOfCourts': numberOfCourts,
    'gameDuration': gameDuration,
    'currency': currency,
    'price': price,
    'schedule': schedule,
    'imageUrl': imageUrl,
    'managerId': managerId,
    'phone': phone,
  };

  factory ClubModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      address: data['address'] ?? '',
      numberOfCourts: data['numberOfCourts'] ?? 1,
      gameDuration: data['gameDuration'] ?? 60,
      currency: data['currency'] ?? 'ILS',
      price: (data['price'] ?? 0).toDouble(),
      schedule: Map<String, Map<String, dynamic>>.from(data['schedule'] ?? {}),
      imageUrl: data['imageUrl'],
      managerId: data['managerId'] ?? '',
      phone: data['phone'],
    );
  }
}
