import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:test01/providers/user_provider.dart'; // Adjust path as needed
import 'package:test01/pages/booking_details.dart'; // Adjust path as needed

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startStatusCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStatusCheck() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndUpdateStatuses();
    });
    _checkAndUpdateStatuses(); // Initial check on load
  }

  Future<void> _checkAndUpdateStatuses() async {
    final userEmail =
        Provider.of<UserProvider>(context, listen: false).userEmail ??
        'unknown';
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('hh:mm a');

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('userEmail', isEqualTo: userEmail)
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final fromDate = dateFormat.parse(data['fromDate']);
        final startTime = timeFormat.parse(data['startTime']);
        final startDateTime = DateTime(
          fromDate.year,
          fromDate.month,
          fromDate.day,
          startTime.hour,
          startTime.minute,
        );
        final status = data['status'] ?? 'Pending';

        if (now.isAfter(startDateTime) &&
            status != 'Cancelled' &&
            status != 'Confirmed' &&
            status != 'No Response') {
          await FirebaseFirestore.instance
              .collection('bookings')
              .doc(doc.id)
              .update({'status': 'No Response'});
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  Future<void> _onRefresh() async {
    await _checkAndUpdateStatuses(); // Trigger status check on refresh
    // The StreamBuilder will automatically update due to the stream subscription
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<UserProvider>(context).userEmail ?? 'unknown';

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings'), elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('bookings')
                .where('userEmail', isEqualTo: userEmail)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          final bookings = snapshot.data!.docs;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index].data() as Map<String, dynamic>;
                final bookingId = bookings[index].id;

                final dateFormat = DateFormat('yyyy-MM-dd');
                final date = dateFormat.parse(booking['fromDate']);
                final startTime = booking['startTime'];
                final endTime = booking['endTime'];
                final reason =
                    booking['reason'] as String? ?? 'No reason provided';
                final status = booking['status'] ?? 'Pending';

                final timeFormat = DateFormat('hh:mm a');
                final startDateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  TimeOfDay.fromDateTime(timeFormat.parse(startTime)).hour,
                  TimeOfDay.fromDateTime(timeFormat.parse(startTime)).minute,
                );
                final now = DateTime.now();
                final isPastStartTime = now.isAfter(startDateTime);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isPastStartTime ? Colors.grey[200] : null,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BookingDetailsPage(bookingId: bookingId),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  booking['placeName'],
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildStatusChip(status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEEE, MMMM d, y').format(date),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '$startTime - $endTime',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Text(
                            'Reason: $reason',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          // Display requested facilities
                          if (booking.containsKey('requestedFacilities') && 
                              booking['requestedFacilities'] is List && 
                              (booking['requestedFacilities'] as List).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_offer, size: 16, color: Colors.deepPurple),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Facilities:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: (booking['requestedFacilities'] as List).map<Widget>((facility) {
                                      final facilityName = facility is Map ? facility['name'] ?? '' : facility.toString();
                                      if (facilityName.isEmpty) return const SizedBox.shrink();
                                      
                                      return Chip(
                                        label: Text(
                                          facilityName,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                                        labelStyle: const TextStyle(color: Colors.deepPurple),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isPastStartTime)
                                TextButton(
                                  onPressed:
                                      (status.toLowerCase() != 'cancelled' &&
                                              status.toLowerCase() !=
                                                  'confirmed')
                                          ? () {
                                            _showCancelConfirmation(
                                              context,
                                              bookingId,
                                            );
                                          }
                                          : null,
                                  child: const Text('Cancel'),
                                ),
                              if (!isPastStartTime) const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => BookingDetailsPage(
                                            bookingId: bookingId,
                                          ),
                                    ),
                                  );
                                },
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCancelConfirmation(
    BuildContext context,
    String bookingId,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text('Are you sure you want to cancel this booking?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _cancelBooking(bookingId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'Cancelled'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cancelling booking: $e')));
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'no response':
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Extension for TimeOfDay parsing
extension on DateTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
