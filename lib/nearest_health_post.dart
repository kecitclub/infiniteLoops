import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class NearestHealthPost extends StatefulWidget {
  const NearestHealthPost({super.key});

  @override
  State<NearestHealthPost> createState() => _NearestHealthPostState();
}

class _NearestHealthPostState extends State<NearestHealthPost> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
        _isLoading = false;
      });

      // Add some sample health posts (replace with real data from an API)
      _addSampleHealthPosts();
    } catch (e) {
      print('Error getting location: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addSampleHealthPosts() {
    // Add sample health posts (replace with real data)
    if (_currentPosition != null) {
      final List<Map<String, dynamic>> healthPosts = [
        {
          'name': 'City Hospital',
          'lat': _currentPosition!.latitude + 0.01,
          'lng': _currentPosition!.longitude + 0.01,
          'contact': '+977-1-4123456',
        },
        {
          'name': 'Community Health Center',
          'lat': _currentPosition!.latitude - 0.01,
          'lng': _currentPosition!.longitude - 0.01,
          'contact': '+977-1-4789012',
        },
        // Add more health posts as needed
      ];

      for (var post in healthPosts) {
        _markers.add(
          Marker(
            markerId: MarkerId(post['name']),
            position: LatLng(post['lat'], post['lng']),
            infoWindow: InfoWindow(
              title: post['name'],
              snippet: 'Contact: ${post['contact']}',
            ),
          ),
        );
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Health Posts'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(child: Text('Unable to get location'))
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 14,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search for health posts',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              // Implement search functionality
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
} 