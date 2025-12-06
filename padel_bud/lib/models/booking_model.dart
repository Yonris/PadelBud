class BookingModel {
  final String id;
  final String userId;
  final String courtId;
  final String timeSlotId;

  BookingModel({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.timeSlotId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'courtId': courtId,
    'timeSlotId': timeSlotId,
  };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id'],
    userId: json['userId'],
    courtId: json['courtId'],
    timeSlotId: json['timeSlotId'],
  );
}
