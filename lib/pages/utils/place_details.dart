import 'package:flutter/material.dart';

/// A page that displays detailed information about a specific place.
///
/// This widget provides a view for showing comprehensive details about
/// a place selected by the user, including its name and other relevant information.
class PlaceDetailPage extends StatefulWidget {
  /// The name of the place to display details for.
  final String placeName;

  const PlaceDetailPage({super.key, required this.placeName});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.placeName),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Details of ${widget.placeName}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // Placeholder for actual content - to be replaced with real data
              const Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "Place information will be displayed here",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
