import 'package:flutter/material.dart';
import 'package:foodie/screens/history_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
 // Import the HistoryScreen file
 import 'package:foodie/screens/prediction_history.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LatLng? _pickedLocation;

  Future<String?> getPlaceAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return null;
      }
      final place = placemarks[0];
      return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } catch (error) {
      print("Error obtaining address: $error");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Location"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _pickedLocation == null
                ? null
                : () {
                    Navigator.of(context).pop(_pickedLocation);
                  },
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(7.8731, 80.7718),
              zoom: 14,
            ),
            onTap: (location) async {
              final address = await getPlaceAddress(location.latitude, location.longitude);
              if (address != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(address)));
              }
              setState(() {
                _pickedLocation = location;
              });
            },
            markers: _pickedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: MarkerId("selectedLocation"),
                      position: _pickedLocation!,
                    ),
                  },
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 0.5,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: HistoryScreenUpdated(),  // Add your HistoryScreen here
              );
            },
          ),
        ],
      ),
    );
  }
}
