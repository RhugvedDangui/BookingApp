import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingActionPage extends StatefulWidget {
  final String bookingId;

  const BookingActionPage({super.key, required this.bookingId});

  @override
  State<BookingActionPage> createState() => _BookingActionPageState();
}

class _BookingActionPageState extends State<BookingActionPage> {
  late TextEditingController _messageController;
  Map<String, dynamic>? _bookingData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _fetchBookingData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookingData() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('bookings')
              .doc(widget.bookingId)
              .get();
      if (doc.exists) {
        setState(() {
          _bookingData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
          debugPrint('Booking status: ${_bookingData!['status']}');
        });
      } else {
        debugPrint('No document found for bookingId: ${widget.bookingId}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching booking: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
            'status': newStatus,
            'adminMessage': _messageController.text.trim(),
            'actionTimestamp': FieldValue.serverTimestamp(),
          });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking $newStatus successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating booking: $e')));
    }
  }

  Future<void> _showConfirmationDialog(String action) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action this booking?'),
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
                if (action == 'Approve') {
                  _updateBookingStatus('Confirmed');
                } else if (action == 'Reject') {
                  _updateBookingStatus('Cancelled');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Action'),
        backgroundColor: Colors.deepPurple.shade600,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _bookingData == null
              ? const Center(
                child: Text(
                  'Booking not found',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User-Entered Booking Details Card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _bookingData!['placeName'] ?? '-',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              icon: Icons.person,
                              label: 'User',
                              value: _bookingData!['userEmail'] ?? '-',
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              label: 'From Date',
                              value:
                                  _bookingData!['fromDate'] != null
                                      ? DateFormat('EEEE, MMMM d, y').format(
                                        DateFormat(
                                          'yyyy-MM-dd',
                                        ).parse(_bookingData!['fromDate']),
                                      )
                                      : 'N/A',
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              label: 'To Date',
                              value:
                                  _bookingData!['toDate'] != null
                                      ? DateFormat('EEEE, MMMM d, y').format(
                                        DateFormat(
                                          'yyyy-MM-dd',
                                        ).parse(_bookingData!['toDate']),
                                      )
                                      : 'N/A',
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              icon: Icons.access_time,
                              label: 'Time',
                              value:
                                  '${_bookingData!['startTime'] ?? 'N/A'} - ${_bookingData!['endTime'] ?? 'N/A'}',
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              icon: Icons.description,
                              label: 'Reason',
                              value: _bookingData!['reason'] ?? '-',
                              isBold: true,
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              icon: Icons.note,
                              label: 'Description',
                              value:
                                  _bookingData!['description']?.isNotEmpty ??
                                          false
                                      ? _bookingData!['description']
                                      : '-',
                            ),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              icon: Icons.schedule,
                              label: 'Requested At',
                              value:
                                  _bookingData!['timestamp'] != null
                                      ? DateFormat(
                                        'yyyy-MM-dd HH:mm:ss',
                                      ).format(
                                        (_bookingData!['timestamp']
                                                as Timestamp)
                                            .toDate(),
                                      )
                                      : 'N/A',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Message Input
                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Admin Message (optional)',
                        hintText: 'e.g., Approved due to availability',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.message,
                          color: Colors.deepPurpleAccent,
                        ),
                        labelStyle: const TextStyle(fontSize: 18),
                      ),
                      maxLines: 4,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed:
                              () => _showConfirmationDialog(
                                'Reject',
                              ), // Always enabled
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              _isApproveEnabled()
                                  ? () => _showConfirmationDialog('Approve')
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Approve',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  // Helper method to determine if Approve should be enabled
  bool _isApproveEnabled() {
    final status = _bookingData!['status']?.toLowerCase();
    // Enable Approve only if status is "pending" or null, disable if "cancelled"
    final isEnabled =
        (status == 'pending' || status == null) && status != 'cancelled';
    debugPrint('Approve enabled: $isEnabled (status: $status)');
    return isEnabled;
  }

  // Helper method to build detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurpleAccent),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isBold ? Colors.grey.shade700 : Colors.grey.shade600,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
