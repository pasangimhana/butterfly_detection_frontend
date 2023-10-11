import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController _controller;
  LatLng? _pickedLocation;


  Future<String?> getPlaceAddress(double lat, double lng) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

    if (placemarks.isEmpty) {
      return null;
    }

    final place = placemarks[0];

    // This is a basic address format, you can customize it as needed.
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
    body: GoogleMap(
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
          )
        },
),

    );
  }
}
