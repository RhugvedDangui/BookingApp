import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:test01/providers/user_provider.dart';

class BookingsPage extends StatefulWidget {
  final String? initialPlaceName;

  const BookingsPage({super.key, this.initialPlaceName});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placeNameController;
  late TextEditingController _descriptionController;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(
    hour: TimeOfDay.now().hour + 1,
  );

  @override
  void initState() {
    super.initState();
    _placeNameController = TextEditingController(
      text: widget.initialPlaceName ?? '',
    );
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          _toDate = picked;
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
          _endTime = TimeOfDay(
            hour: (picked.hour + 1) % 24,
            minute: picked.minute,
          );
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get the user's email from UserProvider
        final userEmail =
            Provider.of<UserProvider>(context, listen: false).userEmail ??
            'unknown';

        // Format the dates to remove time part (store only date)
        String formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate);
        String formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate);

        // Add data to Firestore including the user's email
        await FirebaseFirestore.instance.collection('bookings').add({
          'placeName': _placeNameController.text,
          'fromDate': formattedFromDate,
          'toDate': formattedToDate,
          'startTime': _startTime.format(context),
          'endTime': _endTime.format(context),
          'description': _descriptionController.text,
          'userEmail': userEmail,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear the form fields after successful submission
        setState(() {
          _placeNameController.clear();
          _descriptionController.clear();
          _fromDate = DateTime.now();
          _toDate = DateTime.now();
          _startTime = TimeOfDay.now();
          _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking successfully submitted!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Place').animate().fadeIn().slideX(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                      ).animate().fadeIn().slideX(),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a place name';
                          }
                          return null;
                        },
                      ).animate().fadeIn().slideX(),
                    ],
                  ),
                ),
              ).animate().scale(),

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
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'From Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('EEEE, MMMM d, y').format(_fromDate),
                          ),
                        ),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'To Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('EEEE, MMMM d, y').format(_toDate),
                          ),
                        ),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context, true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Start Time',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.access_time),
                                ),
                                child: Text(_startTime.format(context)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context, false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'End Time',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.access_time),
                                ),
                                child: Text(_endTime.format(context)),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn().slideX(),
                    ],
                  ),
                ),
              ).animate().scale(),

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
                        'Additional Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ).animate().fadeIn().slideX(),
                    ],
                  ),
                ),
              ).animate().scale(),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Submit Booking'),
                ),
              ).animate().scale(),
            ],
          ),
        ),
      ),
    );
  }
}
