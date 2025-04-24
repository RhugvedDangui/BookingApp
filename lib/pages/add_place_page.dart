import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Page for adding new places to the system.
///
/// This page allows administrators to add new places with details
/// and associated facilities.
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
  final _facilityController = TextEditingController();
  final _facilityEmailController = TextEditingController();
  String _status = 'available';
  bool _isSaving = false;
  List<Map<String, String>> _facilities = [];

  /// Adds a new facility to the list
  void _addFacility() {
    final facility = _facilityController.text.trim();
    final email = _facilityEmailController.text.trim();

    if (facility.isEmpty) {
      _showSnackBar('Facility name cannot be empty');
      return;
    }

    setState(() {
      _facilities.add({
        'name': facility,
        'email': email,
      });
      _facilityController.clear();
      _facilityEmailController.clear();
    });
  }

  /// Removes a facility from the list
  void _removeFacility(int index) {
    setState(() {
      _facilities.removeAt(index);
    });
  }

  /// Validates and saves the place to Firestore
  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final placeData = {
        'name': _nameController.text.trim(),
        'details': _detailsController.text.trim(),
        'capacity': int.parse(_capacityController.text.trim()),
        'location': _locationController.text.trim(),
        'status': _status,
        'facilities': _facilities,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('places').add(placeData);
      _showSnackBar('Place added successfully');
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      _showSnackBar('Firestore error: ${e.message}');
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Shows a snackbar with the given message
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
    _facilityController.dispose();
    _facilityEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place').animate().fadeIn(duration: 300.milliseconds).slideX(),
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
                  _buildPlaceDetailsCard(),
                  const SizedBox(height: 16),
                  _buildFacilitiesCard(),
                  const SizedBox(height: 16),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
          if (_isSaving) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  /// Builds the place details input card
  Widget _buildPlaceDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Place Details', style: Theme.of(context).textTheme.titleLarge)
                .animate()
                .fadeIn(duration: 300.milliseconds)
                .slideX(),
            const SizedBox(height: 16),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDetailsField(),
            const SizedBox(height: 16),
            _buildCapacityField(),
            const SizedBox(height: 16),
            _buildLocationField(),
          ],
        ),
      ),
    ).animate().scale(duration: 300.milliseconds);
  }

  /// Builds the facilities management card
  Widget _buildFacilitiesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Facilities', style: Theme.of(context).textTheme.titleLarge)
                .animate()
                .fadeIn(duration: 300.milliseconds)
                .slideX(),
            const SizedBox(height: 16),
            _buildFacilityInputFields(),
            const SizedBox(height: 16),
            _buildFacilitiesList(),
          ],
        ),
      ),
    );
  }

  /// Builds the save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _savePlace,
        child: const Text('Save Place'),
      ),
    );
  }

  /// Builds the loading indicator
  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Builds the name input field
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Place Name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.place),
      ),
      validator: (value) => value!.isEmpty ? 'Enter a name' : null,
    ).animate().fadeIn(duration: 300.milliseconds).slideX();
  }

  /// Builds the details input field
  Widget _buildDetailsField() {
    return TextFormField(
      controller: _detailsController,
      decoration: InputDecoration(
        labelText: 'Details',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.info),
      ),
      maxLines: 2,
      validator: (value) => value!.isEmpty ? 'Enter details' : null,
    ).animate().fadeIn(duration: 300.milliseconds).slideX();
  }

  /// Builds the capacity input field
  Widget _buildCapacityField() {
    return TextFormField(
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
    ).animate().fadeIn(duration: 300.milliseconds).slideX();
  }

  /// Builds the location input field
  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'Location',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.location_on),
      ),
      validator: (value) => value!.isEmpty ? 'Enter a location' : null,
    ).animate().fadeIn(duration: 300.milliseconds).slideX();
  }

  /// Builds the facility input fields
  Widget _buildFacilityInputFields() {
    return Column(
      children: [
        TextFormField(
          controller: _facilityController,
          decoration: InputDecoration(
            labelText: 'Facility Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.room_service),
          ),
          validator: (value) => value!.isEmpty ? 'Enter facility name' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _facilityEmailController,
          decoration: InputDecoration(
            labelText: 'Facility Contact Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isNotEmpty && !value.contains('@')) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addFacility,
            child: const Text('Add Facility'),
          ),
        ),
      ],
    );
  }

  /// Builds the list of facilities
  Widget _buildFacilitiesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Added Facilities', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._facilities.map((facility) {
          final index = _facilities.indexOf(facility);
          return ListTile(
            title: Text(facility['name'] ?? ''),
            subtitle: Text(facility['email']?.isNotEmpty == true ? facility['email']! : 'No email provided'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeFacility(index),
            ),
          );
        }).toList(),
      ],
    );
  }
}