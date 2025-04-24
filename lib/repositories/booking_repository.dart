import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getBooking(String bookingId) async {
    return await _firestore.collection('bookings').doc(bookingId).get();
  }

  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) async {
    await _firestore.collection('bookings').doc(bookingId).update(data);
  }

  Future<QuerySnapshot> getUserBookings(String userEmail) async {
    return await _firestore
        .collection('bookings')
        .where('userEmail', isEqualTo: userEmail)
        .orderBy('timestamp', descending: true)
        .get();
  }
}
