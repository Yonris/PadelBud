import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final _db = FirebaseFirestore.instance.collection('bookings');

  Future<void> createBooking(BookingModel booking) async {
    await _db.doc(booking.id).set(booking.toJson());
  }
}
