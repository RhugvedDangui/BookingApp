import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test01/providers/user_provider.dart'; // Adjust path as needed
import 'package:provider/provider.dart';

class BookingDetailsPage extends StatefulWidget {
  final String bookingId;

  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placeNameController;
  late TextEditingController _descriptionController;
  late DateTime _fromDate;
  late DateTime _toDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String _status = 'Pending';
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _placeNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
    _fetchBookingData();
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _descriptionController.dispose();
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
        final data = doc.data() as Map<String, dynamic>;
        final dateFormat = DateFormat('yyyy-MM-dd');
        final timeFormat = DateFormat('hh:mm a');

        setState(() {
          _placeNameController.text = data['placeName'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _fromDate = dateFormat.parse(data['fromDate']);
          _toDate = dateFormat.parse(data['toDate']);
          _startTime = TimeOfDay.fromDateTime(
            timeFormat.parse(data['startTime']),
          );
          _endTime = TimeOfDay.fromDateTime(timeFormat.parse(data['endTime']));
          _status = data['status'] ?? 'Pending';
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching booking: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          if (_toDate.isBefore(_fromDate)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          if (_endTime.hour <= _startTime.hour && _fromDate == _toDate) {
            _endTime = _startTime.replacing(hour: _startTime.hour + 1);
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dateFormat = DateFormat('yyyy-MM-dd');
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .update({
              'placeName':
                  _placeNameController
                      .text, // Still included in update, but not editable
              'fromDate': dateFormat.format(_fromDate),
              'toDate': dateFormat.format(_toDate),
              'startTime': _startTime.format(context),
              'endTime': _endTime.format(context),
              'description': _descriptionController.text,
              'timestamp': FieldValue.serverTimestamp(),
            });
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating booking: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFormat = DateFormat('hh:mm a');
    final startDateTime = timeFormat
        .parse(_startTime.format(context))
        .copyWith(
          year: _fromDate.year,
          month: _fromDate.month,
          day: _fromDate.day,
        );
    final isPastStartTime = now.isAfter(startDateTime);
    final isEditable = !isPastStartTime && _status.toLowerCase() != 'confirmed';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        elevation: 0,
        actions: [
          if (isEditable && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Place Details',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _placeNameController,
                                decoration: InputDecoration(
                                  labelText: 'Place Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.place),
                                ),
                                enabled: false, // Always disabled
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a place name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.description),
                                ),
                                enabled: _isEditing && isEditable,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date & Time',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap:
                                    _isEditing && isEditable
                                        ? () => _selectDate(context, true)
                                        : null,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'From Date',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'EEEE, MMMM d, y',
                                    ).format(_fromDate),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap:
                                    _isEditing && isEditable
                                        ? () => _selectDate(context, false)
                                        : null,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'To Date',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'EEEE, MMMM d, y',
                                    ).format(_toDate),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap:
                                          _isEditing && isEditable
                                              ? () => _selectTime(context, true)
                                              : null,
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Start Time',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.access_time,
                                          ),
                                        ),
                                        child: Text(_startTime.format(context)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: InkWell(
                                      onTap:
                                          _isEditing && isEditable
                                              ? () =>
                                                  _selectTime(context, false)
                                              : null,
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'End Time',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.access_time,
                                          ),
                                        ),
                                        child: Text(_endTime.format(context)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isEditing && isEditable) ...[
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}

// Extension for TimeOfDay parsing
extension on DateTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
