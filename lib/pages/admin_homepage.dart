import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:test01/pages/add_place_page.dart';
import 'package:test01/pages/edit_place_page.dart';
import 'package:test01/pages/admin_requests.dart'; // Added AdminRequestsPage
import 'package:test01/pages/settings.dart'; // SettingsPage
import 'package:test01/pages/utils/bottom_nav.dart'; // Custom bottom nav

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({Key? key}) : super(key: key);

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('Navigated to index: $index'); // Debug print
    });
  }

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Home Screen (Original AdminHomepage content)
      SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[50]!, Colors.grey[100]!],
            ),
          ),
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('places').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: const Duration(milliseconds: 300)),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading places...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_off, size: 64, color: Colors.blue[300]),
                              const SizedBox(height: 16),
                              const Text(
                                'No places found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first place using the + button',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ).animate().fadeIn().scale(delay: const Duration(milliseconds: 200)),
                      );
                    }

                    final places = snapshot.data!.docs;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // Adjust crossAxisCount based on width
                        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            final place = places[index].data() as Map<String, dynamic>;
                            final docId = places[index].id;
                            final name = place['name'] as String? ?? 'Unnamed Place';
                            final details = place['details'] as String? ?? 'No details';
                            final capacity = place['capacity'] as int? ?? 0;
                            final location = place['location'] as String? ?? 'No location';
                            final status = place['status'] as String? ?? 'Unknown';

                            List<String> facilities = [];
                            if (place.containsKey('facilities') && place['facilities'] is List) {
                              // Handle both old format (list of strings) and new format (list of maps)
                              final facilitiesList = place['facilities'] as List;
                              facilities = facilitiesList.map((facility) {
                                if (facility is String) {
                                  return facility;
                                } else if (facility is Map) {
                                  return facility['name'] as String? ?? 'Unknown facility';
                                }
                                return 'Unknown facility';
                              }).toList().cast<String>();
                            }

                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (constraints.maxWidth / crossAxisCount) - 20,
                              ),
                              child: Card(
                                elevation: 6,
                                shadowColor: Colors.black38,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Colors.white, Colors.grey[50]!],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.indigo[700],
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blueAccent,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditPlacePage(
                                                      docId: docId,
                                                      initialData: place,
                                                    ),
                                                  ),
                                                );
                                              },
                                              tooltip: 'Edit Place',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minHeight: 32,
                                                minWidth: 32,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 10),
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Details: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey[800],
                                                    ),
                                              ),
                                              TextSpan(
                                                text: details,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      color: Colors.grey[800],
                                                    ),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      _buildInfoRow(
                                        context: context,
                                        icon: Icons.people,
                                        label: 'Capacity: ',
                                        value: '$capacity',
                                      ),
                                      const SizedBox(height: 6),
                                      _buildInfoRow(
                                        context: context,
                                        icon: Icons.location_on,
                                        label: 'Location: ',
                                        value: location,
                                      ),
                                      if (facilities.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.local_offer,
                                              size: 14,
                                              color: Colors.indigo[400],
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Facilities:',
                                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Wrap(
                                                    spacing: 4,
                                                    runSpacing: 4,
                                                    children: facilities.take(3).map((facility) {
                                                      return Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue[50],
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(color: Colors.blue[100]!),
                                                        ),
                                                        child: Text(
                                                          facility,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.blue[800],
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                  if (facilities.length > 3)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 2),
                                                      child: Text(
                                                        '+${facilities.length - 3} more',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey[600],
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const Spacer(),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: status == 'available'
                                                ? [Colors.green[100]!, Colors.green[200]!]
                                                : [Colors.red[100]!, Colors.red[200]!],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (status == 'available' ? Colors.green : Colors.red)
                                                  .withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              status == 'available' ? Icons.check_circle : Icons.cancel,
                                              size: 14,
                                              color: status == 'available'
                                                  ? Colors.green[800]
                                                  : Colors.red[800],
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  color: status == 'available'
                                                      ? Colors.green[800]
                                                      : Colors.red[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate(delay: Duration(milliseconds: 50 * index))
                              .fadeIn(duration: const Duration(milliseconds: 300))
                              .slideY(begin: 0.2, end: 0)
                              .then()
                              .shimmer(duration: const Duration(milliseconds: 600));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Admin Requests Page (replacing BookingsPage)
      const AdminRequestsPage(),
      // Notifications Page (placeholder)
      const Center(
        child: Text('Notifications Page'),
      ),
      // Settings Page
      const SettingsPage(),
    ];
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo[700]!, Colors.blue[500]!],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'Manage Places',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // Search functionality
                },
                tooltip: 'Search Places',
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  // Filter functionality
                },
                tooltip: 'Filter Places',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.indigo[400],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.grey[800],
                      ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPlacePage()),
                );
              },
              backgroundColor: Colors.indigo[600],
              icon: const Icon(Icons.add),
              label: const Text('Add Place'),
              elevation: 6,
              tooltip: 'Add New Place',
            ).animate()
              .scale(duration: const Duration(milliseconds: 300))
              .shimmer(delay: const Duration(milliseconds: 1000), duration: const Duration(milliseconds: 700))
          : null, // Show FAB only on home screen
    );
  }
}