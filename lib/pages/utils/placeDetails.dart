import 'package:flutter/material.dart';

class PlaceDetailPage extends StatefulWidget {
  final String placeName;

  const PlaceDetailPage({super.key, required this.placeName}); // Added required parameter

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.placeName)), // Use widget.placeName
      body: Center(child: Text("Details of ${widget.placeName}")), // Display place name
    );
  }
}
