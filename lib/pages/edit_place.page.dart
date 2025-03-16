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
  late String _status;
  bool _isSaving = false;

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
    // Normalize status to match dropdown options
    final initialStatus = widget.initialData['status'] ?? 'available';
    _status =
        (initialStatus == 'unavailable' || initialStatus == 'not available')
            ? 'not available'
            : 'available';
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
          'createdAt':
              widget.initialData['createdAt'] ??
              Timestamp.now(), // Preserve original timestamp
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
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
