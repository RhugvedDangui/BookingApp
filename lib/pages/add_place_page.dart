import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddPlacePage extends StatefulWidget {
  const AddPlacePage({Key? key}) : super(key: key);

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();
  String _status = 'available';
  bool _isSaving = false;

  Future<void> _savePlace() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final placeName = _nameController.text.trim();
        print('Starting save process for place: $placeName');

        final placeData = {
          'name': placeName,
          'details': _detailsController.text.trim(),
          'capacity': int.parse(_capacityController.text.trim()),
          'location': _locationController.text.trim(),
          'status': _status,
          'createdAt': Timestamp.now(),
        };

        print('Saving to Firestore: $placeData');
        await FirebaseFirestore.instance.collection('places').add(placeData);
        print('Place saved successfully');

        _showSnackBar('Place added successfully');
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Error adding place: $e');
        print('Save error: $e');
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place').animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Place Details', style: Theme.of(context).textTheme.titleLarge)
                              .animate()
                              .fadeIn(duration: const Duration(milliseconds: 300))
                              .slideX(),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Place Name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.place),
                            ),
                            validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _detailsController,
                            decoration: InputDecoration(
                              labelText: 'Details',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.info),
                            ),
                            maxLines: 2,
                            validator: (value) => value!.isEmpty ? 'Enter details' : null,
                          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _capacityController,
                            decoration: InputDecoration(
                              labelText: 'Capacity',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.people),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) return 'Enter capacity';
                              if (int.tryParse(value) == null) return 'Enter a valid number';
                              return null;
                            },
                          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.location_on),
                            ),
                            validator: (value) => value!.isEmpty ? 'Enter a location' : null,
                          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
                        ],
                      ),
                    ),
                  ).animate().scale(duration: const Duration(milliseconds: 300)),

                  const SizedBox(height: 16),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status', style: Theme.of(context).textTheme.titleLarge)
                              .animate()
                              .fadeIn(duration: const Duration(milliseconds: 300))
                              .slideX(),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.check_circle),
                            ),
                            items: ['available', 'not available']
                                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                .toList(),
                            onChanged: (value) => setState(() => _status = value!),
                            validator: (value) => value == null ? 'Select a status' : null,
                          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideX(),
                        ],
                      ),
                    ),
                  ).animate().scale(duration: const Duration(milliseconds: 300)),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePlace,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Place'),
                    ),
                  ).animate().scale(duration: const Duration(milliseconds: 300)),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}