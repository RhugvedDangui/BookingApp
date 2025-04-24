import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditPlacePage extends StatefulWidget {
  final String docId; // Document ID to update
  final Map<String, dynamic> initialData; // Existing data to pre-fill

  const EditPlacePage({
    Key? key,
    required this.docId,
    required this.initialData,
  }) : super(key: key);

  @override
  State<EditPlacePage> createState() => _EditPlacePageState();
}

class _EditPlacePageState extends State<EditPlacePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _detailsController;
  late final TextEditingController _capacityController;
  late final TextEditingController _locationController;
  late final TextEditingController _facilityController; // Controller for facility name
  late final TextEditingController _facilityEmailController; // Controller for facility email
  late String _status;
  bool _isSaving = false;
  
  // Updated to store facility objects with name and email
  List<Map<String, String>> _facilities = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with initial data
    _nameController = TextEditingController(
      text: widget.initialData['name'] ?? '',
    );
    _detailsController = TextEditingController(
      text: widget.initialData['details'] ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.initialData['capacity']?.toString() ?? '0',
    );
    _locationController = TextEditingController(
      text: widget.initialData['location'] ?? '',
    );
    _facilityController = TextEditingController(); // Initialize facility controller
    _facilityEmailController = TextEditingController(); // Initialize facility email controller
    
    // Load existing facilities if available
    if (widget.initialData.containsKey('facilities')) {
      if (widget.initialData['facilities'] is List) {
        final facilitiesList = widget.initialData['facilities'] as List;
        
        // Check if facilities are stored as maps or strings
        if (facilitiesList.isNotEmpty) {
          if (facilitiesList.first is Map) {
            // If facilities are already stored as maps with name and email
            _facilities = facilitiesList.map<Map<String, String>>((facility) {
              // Safely convert from Map<String, dynamic> to Map<String, String>
              return {
                'name': (facility['name'] ?? '').toString(),
                'email': (facility['email'] ?? '').toString(),
              };
            }).toList();
          } else if (facilitiesList.first is String) {
            // If facilities are stored as simple strings (old format), convert to new format
            _facilities = facilitiesList.map<Map<String, String>>((facility) {
              return {
                'name': facility.toString(),
                'email': '',
              };
            }).toList();
          }
        }
      }
    }
    
    // Normalize status to match dropdown options
    final initialStatus = widget.initialData['status'] ?? 'available';
    _status =
        (initialStatus == 'unavailable' || initialStatus == 'not available')
            ? 'not available'
            : 'available';
  }

  // Add a facility to the list
  void _addFacility() {
    final facility = _facilityController.text.trim();
    final email = _facilityEmailController.text.trim();
    
    if (facility.isNotEmpty) {
      setState(() {
        // Add facility with email (email can be empty)
        _facilities.add({
          'name': facility,
          'email': email,
        });
        _facilityController.clear();
        _facilityEmailController.clear();
      });
    }
  }

  // Remove a facility from the list
  void _removeFacility(int index) {
    setState(() {
      _facilities.removeAt(index);
    });
  }

  Future<void> _savePlace() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final placeData = {
          'name': _nameController.text.trim(),
          'details': _detailsController.text.trim(),
          'capacity': int.parse(_capacityController.text.trim()),
          'location': _locationController.text.trim(),
          'status': _status,
          'facilities': _facilities, // Save facilities with emails to Firestore
          'createdAt':
              widget.initialData['createdAt'] ??
              Timestamp.now(), // Preserve original timestamp
          'updatedAt': Timestamp.now(), // Add update timestamp
        };

        await FirebaseFirestore.instance
            .collection('places')
            .doc(widget.docId)
            .update(placeData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating place: $e')));
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    _facilityController.dispose();
    _facilityEmailController.dispose(); // Dispose facility email controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 16,
                    ), // Top padding like AdminHomepage
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
                                  'Edit Place Details',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 300),
                                )
                                .slideX(),
                            const SizedBox(height: 16),
                            TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Place Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.place,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Enter a name'
                                              : null,
                                )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 300),
                                )
                                .slideX(),
                            const SizedBox(height: 16),
                            TextFormField(
                                  controller: _detailsController,
                                  decoration: InputDecoration(
                                    labelText: 'Details',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.info,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Enter details'
                                              : null,
                                )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 300),
                                )
                                .slideX(),
                            const SizedBox(height: 16),
                            TextFormField(
                                  controller: _capacityController,
                                  decoration: InputDecoration(
                                    labelText: 'Capacity',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.people,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value!.isEmpty) return 'Enter capacity';
                                    if (int.tryParse(value) == null)
                                      return 'Enter a valid number';
                                    return null;
                                  },
                                )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 300),
                                )
                                .slideX(),
                            const SizedBox(height: 16),
                            TextFormField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                    labelText: 'Location',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.location_on,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Enter a location'
                                              : null,
                                )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 300),
                                )
                                .slideX(),
                          ],
                        ),
                      ),
                    ).animate().scale(
                      duration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 16),
                    // New card for facilities
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
                              'Facilities',
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ).animate().fadeIn(
                              duration: const Duration(milliseconds: 300),
                            ).slideX(),
                            const SizedBox(height: 16),
                            
                            // Facility name field
                            TextFormField(
                              controller: _facilityController,
                              decoration: InputDecoration(
                                labelText: 'Facility Name',
                                hintText: 'e.g., WiFi, Parking, Cafeteria',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.local_offer, color: Colors.grey),
                              ),
                            ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
                            
                            const SizedBox(height: 12),
                            
                            // Facility email field
                            TextFormField(
                              controller: _facilityEmailController,
                              decoration: InputDecoration(
                                labelText: 'Contact Email (Optional)',
                                hintText: 'e.g., facility.manager@example.com',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.email, color: Colors.grey),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
                            
                            const SizedBox(height: 12),
                            
                            // Add facility button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _addFacility,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Facility'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
                            
                            const SizedBox(height: 16),
                            
                            if (_facilities.isNotEmpty) ...[
                              Text(
                                'Current Facilities:',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _facilities.length,
                                itemBuilder: (context, index) {
                                  final facility = _facilities[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color: Colors.blue[50],
                                    child: ListTile(
                                      title: Text(
                                        facility['name'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: facility['email']!.isNotEmpty
                                          ? Text('Contact: ${facility['email']}')
                                          : const Text('No contact email provided', style: TextStyle(fontStyle: FontStyle.italic)),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeFacility(index),
                                      ),
                                      leading: const Icon(Icons.local_offer, color: Colors.blue),
                                    ),
                                  );
                                },
                              ),
                            ] else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'No facilities added yet',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
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
                                  'Status',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 300),
                                )
                                .slideX(),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                                  value: _status,
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  items:
                                      ['available', 'not available']
                                          .map(
                                            (status) => DropdownMenuItem(
                                              value: status,
                                              child: Text(status),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) =>
                                          setState(() => _status = value!),
                                  validator:
                                      (value) =>
                                          value == null
                                              ? 'Select a status'
                                              : null,
                                )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 300),
                                )
                                .slideX(),
                          ],
                        ),
                      ),
                    ).animate().scale(
                      duration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _savePlace,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Update Place',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ).animate().scale(
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              ),
            ),
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            // Back button
            Positioned(
              top: 40,
              left: 16,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
