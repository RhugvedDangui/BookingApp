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
  late TextEditingController _reasonController;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(
    hour: TimeOfDay.now().hour + 1,
  );
  
  // Lists to track available and selected facilities
  List<Map<String, String>> _availableFacilities = [];
  List<Map<String, String>> _selectedFacilities = [];
  bool _isLoadingFacilities = false;
  String? _placeId; // Add place ID variable

  @override
  void initState() {
    super.initState();
    _placeNameController = TextEditingController(
      text: widget.initialPlaceName ?? '',
    );
    _descriptionController = TextEditingController();
    _reasonController = TextEditingController();
    
    // If a place is pre-selected, fetch its facilities
    if (widget.initialPlaceName != null && widget.initialPlaceName!.isNotEmpty) {
      _fetchPlaceFacilities(widget.initialPlaceName!);
    }
  }

  // Fetch facilities for the selected place
  Future<void> _fetchPlaceFacilities(String placeName) async {
    setState(() {
      _isLoadingFacilities = true;
    });
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('places')
          .where('name', isEqualTo: placeName)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final placeData = querySnapshot.docs.first.data();
        final placeId = querySnapshot.docs.first.id; // Get the place ID
        
        // Store the place ID in the state
        setState(() {
          _placeId = placeId;
        });
        
        if (placeData.containsKey('facilities') && placeData['facilities'] is List) {
          final facilitiesList = placeData['facilities'];
          
          if (facilitiesList.isNotEmpty) {
            // Convert facilities to Map<String, String> format
            final facilities = facilitiesList.map<Map<String, String>>((dynamic facility) {
              if (facility is Map) {
                return {
                  'name': facility['name']?.toString() ?? '',
                  'email': facility['email']?.toString() ?? '',
                };
              } else if (facility is String) {
                return {
                  'name': facility,
                  'email': '',
                };
              }
              return {'name': '', 'email': ''};
            }).where((Map<String, String> facility) => facility['name']!.isNotEmpty).toList();
            
            setState(() {
              _availableFacilities = facilities;
              _isLoadingFacilities = false;
            });
          } else {
            setState(() {
              _availableFacilities = [];
              _isLoadingFacilities = false;
            });
          }
        } else {
          setState(() {
            _availableFacilities = [];
            _isLoadingFacilities = false;
          });
        }
      } else {
        setState(() {
          _availableFacilities = [];
          _isLoadingFacilities = false;
        });
      }
    } catch (e) {
      print('Error fetching facilities: $e');
      setState(() {
        _availableFacilities = [];
        _isLoadingFacilities = false;
      });
    }
  }
  
  // Toggle facility selection
  void _toggleFacility(Map<String, String> facility) {
    setState(() {
      // Check if the facility is already selected (by name)
      final index = _selectedFacilities.indexWhere((f) => f['name'] == facility['name']);
      
      if (index >= 0) {
        // If already selected, remove it
        _selectedFacilities.removeAt(index);
      } else {
        // Otherwise add it
        _selectedFacilities.add(facility);
      }
    });
  }

  Widget _buildFacilityChip(Map<String, String> facility) {
    return FilterChip(
      label: Text(facility['name'] ?? ''),
      selected: _selectedFacilities.any((f) => f['name'] == facility['name']),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedFacilities.add(facility);
          } else {
            _selectedFacilities.removeWhere((f) => f['name'] == facility['name']);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _descriptionController.dispose();
    _reasonController.dispose();
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
        final userEmail =
            Provider.of<UserProvider>(context, listen: false).userEmail ??
            'unknown';
        String formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate);
        String formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate);

        await FirebaseFirestore.instance.collection('bookings').add({
          'placeName': _placeNameController.text,
          'placeId': _placeId, // Add place ID to booking submission
          'fromDate': formattedFromDate,
          'toDate': formattedToDate,
          'startTime': _startTime.format(context),
          'endTime': _endTime.format(context),
          'description': _descriptionController.text,
          'reason': _reasonController.text,
          'userEmail': userEmail,
          'requestedFacilities': _selectedFacilities, // Save selected facilities with emails
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _placeNameController.clear();
          _descriptionController.clear();
          _reasonController.clear();
          _fromDate = DateTime.now();
          _toDate = DateTime.now();
          _startTime = TimeOfDay.now();
          _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
          _selectedFacilities = []; // Clear selected facilities
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
                        enabled: false,
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
              
              // Facilities selection card
              if (_availableFacilities.isNotEmpty)
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
                          'Select Facilities',
                          style: Theme.of(context).textTheme.titleLarge,
                        ).animate().fadeIn().slideX(),
                        const SizedBox(height: 16),
                        _isLoadingFacilities
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: [
                                  Text(
                                    'Select the facilities you need:',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _availableFacilities.map((facility) {
                                      return _buildFacilityChip(facility);
                                    }).toList(),
                                  ),
                                  if (_selectedFacilities.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue[100]!),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Selected Facilities:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[800],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: _selectedFacilities.length,
                                            itemBuilder: (context, index) {
                                              final facility = _selectedFacilities[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons.check, size: 16, color: Colors.green[700]),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            facility['name'] ?? '',
                                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                          if (facility['email'] != null && facility['email']!.isNotEmpty)
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 2),
                                                              child: Text(
                                                                'Contact: ${facility['email']}',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors.blue[700],
                                                                  fontStyle: FontStyle.italic,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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
                        controller: _reasonController,
                        decoration: InputDecoration(
                          labelText: 'Reason for Booking',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.info),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reason for booking';
                          }
                          return null;
                        },
                        maxLines: 2,
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
