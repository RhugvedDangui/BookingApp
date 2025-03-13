import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class BookingsPage extends StatefulWidget {
  final String? initialPlaceName;
  
  const BookingsPage({
    super.key,
    this.initialPlaceName,
  });

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placeNameController;
  late TextEditingController _descriptionController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  
  @override
  void initState() {
    super.initState();
    _placeNameController = TextEditingController(text: widget.initialPlaceName ?? '');
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
          // Automatically set end time to 1 hour after start time
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Place')
          .animate()
          .fadeIn()
          .slideX(),
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
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('EEEE, MMMM d, y').format(_selectedDate),
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
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Add any special requirements or notes for the admin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                      ).animate().fadeIn().slideX(),
                    ],
                  ),
                ),
              ).animate().scale(),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement booking submission
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Processing booking...'),
                        ),
                      );
                    }
                  },
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
