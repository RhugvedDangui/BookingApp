import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:test01/pages/booking_action.dart'; // New page import

class AdminRequestsPage extends StatefulWidget {
  const AdminRequestsPage({super.key});

  @override
  State<AdminRequestsPage> createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  String? _selectedStatus; // For filtering, null means "All"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'User Booking Requests',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
            ),
            // Modern Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildModernFilterChip('All', null),
                    const SizedBox(width: 12),
                    _buildModernFilterChip('Pending', 'Pending'),
                    const SizedBox(width: 12),
                    _buildModernFilterChip('Confirmed', 'Confirmed'),
                    const SizedBox(width: 12),
                    _buildModernFilterChip('Cancelled', 'Cancelled'),
                    const SizedBox(width: 12),
                    _buildModernFilterChip('No Response', 'No Response'),
                  ],
                ),
              ),
            ),
            // Booking List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _selectedStatus == null
                    ? FirebaseFirestore.instance
                        .collection('bookings')
                        .orderBy('timestamp', descending: true)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: _selectedStatus)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red)));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No booking requests found',
                            style: TextStyle(fontSize: 18, color: Colors.grey)));
                  }

                  final bookings = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index].data() as Map<String, dynamic>;
                      final bookingId = bookings[index].id;
                      final userEmail = booking['userEmail'] as String? ?? 'Unknown';
                      final placeName = booking['placeName'] as String? ?? 'Unknown Place';
                      final fromDate = booking['fromDate'] as String? ?? 'N/A';
                      final startTime = booking['startTime'] as String? ?? 'N/A';
                      final endTime = booking['endTime'] as String? ?? 'N/A';
                      final reason = booking['reason'] as String? ?? 'No reason provided';
                      final status = booking['status'] as String? ?? 'Pending';

                      // Parse date for display
                      final dateFormat = DateFormat('yyyy-MM-dd');
                      final displayDate =
                          DateFormat('EEEE, MMMM d, y').format(dateFormat.parse(fromDate));

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingActionPage(bookingId: bookingId),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        placeName,
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    _buildStatusChip(status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'User: ${userEmail.split('@')[0]}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 16, color: Colors.deepPurpleAccent),
                                    const SizedBox(width: 8),
                                    Text(displayDate, style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 16, color: Colors.deepPurpleAccent),
                                    const SizedBox(width: 8),
                                    Text('$startTime - $endTime',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reason: $reason',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideY(
                            begin: 0.2,
                            end: 0,
                          );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Filter Chip Widget
  Widget _buildModernFilterChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.deepPurple.shade600, Colors.deepPurple.shade800]
                : [Colors.deepPurple.shade100, Colors.deepPurple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(isSelected ? 0.4 : 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.deepPurple.shade900,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Status Chip Widget
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