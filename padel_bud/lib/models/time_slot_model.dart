import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlotModel {
  final String id;
  final DateTime start;
  final DateTime end;
  final String courtId;
  final int buddies;
  double price;
  bool available;

  TimeSlotModel({
    required this.id,
    required this.start,
    required this.end,
    required this.courtId,
    required this.buddies,
    required this.price,
    required this.available,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'courtId': courtId,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'buddies': buddies,
    'price': price,
    'available': available,
  };

  factory TimeSlotModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimeSlotModel(
      id: doc.id,
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
      courtId: data['courtId'] ?? '',
      buddies: data['buddies'] ?? 0,
      price: (data['price'] ?? 25.0).toDouble(),
      available: data['available'] ?? false,
    );
  }
}
