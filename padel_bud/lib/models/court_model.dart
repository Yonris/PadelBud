import 'package:cloud_firestore/cloud_firestore.dart';

class CourtModel {
  String id;
  final String name;
  final String clubId;
  final int courtNumber;

  CourtModel({
    required this.id,
    required this.name,
    required this.clubId,
    required this.courtNumber,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'clubId': clubId,
    'courtNumber': courtNumber,
  };
  
  factory CourtModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourtModel(
      id: doc.id,
      name: data['name'] ?? '',
      clubId: data['clubId'] ?? '',
      courtNumber: data['courtNumber'] ?? 1,
    );
  }
}
