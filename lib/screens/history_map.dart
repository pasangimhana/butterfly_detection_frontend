import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants.dart'; // Import your login page

class HistoryScreenUpdated extends StatefulWidget {
  @override
  _HistoryScreenUpdatedState createState() => _HistoryScreenUpdatedState();
}

class _HistoryScreenUpdatedState extends State<HistoryScreenUpdated> {
  List<dynamic> historyList = [];
  late LatLng initialCoordinates;
  late CameraPosition _initialCameraPosition = CameraPosition(
    // TARGET POSITION OF Sri Lanka
    target: LatLng(7.8731, 80.7718),
    zoom: 8.0,
  );

  final Map<String, BitmapDescriptor> butterflyIcons = {
    'Common_Indian_Crow': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    'Common_Jay': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    'Common_Mime_Swallowtail': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    'Common_Rose': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    'Cylon_Blue_Glass_Tiger': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    'Great_eggfly': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    'Lemon_Pansy': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
    'Tailed_Jay': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    'Common_Mormon': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
  };

  Set<Marker> _markers = {};

  // colors for each butterfly class


  // final String apiUrl = 'http://52.184.86.31/history';
  final String apiUrl = '${URL.baseUrl}/history';

  // Create a GoogleMapController reference
  late GoogleMapController _mapController;

  // Initial camera position

  LatLng convertToLatLng(String latitude, String longitude) {
    double lat = double.parse(latitude);
    double lng = double.parse(longitude);
    return LatLng(lat, lng);
  }

  Future<void> deleteHistory(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      fetchHistory(); // Refresh the list after deleting
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete history.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
    // wait for 2 seconds after fetching history
  }

  Future<void> fetchHistory() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        historyList = json.decode(response.body);
        print(historyList);

        if (historyList.isNotEmpty) {
          print(historyList[0]['latitude']);
          print(historyList[0]['longitude']);
          print(double.parse(historyList[0]['longitude']));
          print(double.parse(historyList[0]['latitude']));
          initialCoordinates = LatLng(
            double.parse(historyList[0]['latitude']),
            double.parse(historyList[0]['longitude']),
          );
          _initialCameraPosition = CameraPosition(
            target: initialCoordinates,
            zoom: 10.0,
          );
        }
      });

      for (var item in historyList) {
        LatLng location = convertToLatLng(item['latitude'], item['longitude']);
        _markers.add(
          Marker(
            markerId:
                MarkerId(item['id'].toString()), // Unique ID for each marker
            position: location,
            infoWindow: InfoWindow(
              title: item['detection_class'], // Customize as needed
              snippet: formatLocation(item['location']), // Customize as needed
            ),
            icon: butterflyIcons[item['detection_class']] ?? BitmapDescriptor.defaultMarker,
          ),
        );
      }
    } else {
      throw Exception('Failed to load history');
    }
  }

  String formatLocation(String location) {
    List<String> words = location.split(' ');
    if (words.length > 8) {
      return words.sublist(0, 8).join(' ') + '\n' + words.sublist(8).join(' ');
    }
    return location;
  }

  // New method to format butterfly class
  String formatButterflyClass(String detectionClass) {
    if (detectionClass.length > 25) {
      return detectionClass.substring(0, 25) +
          '\n' +
          detectionClass.substring(25);
    }
    return detectionClass;
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Colors.blue;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Butterfly Detection History'),
      //   actions: <Widget>[
      //     TextButton(
      //       onPressed: () {
      //         // Navigate to the login page when the logout button is clicked
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => SignInPage()),
      //         );
      //       },
      //       child: Text(
      //         'Logout',
      //         style: TextStyle(color: const Color.fromARGB(255, 36, 34, 34)),
      //       ),
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          Container(
            height: 400, // Set your desired height for the map
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
              initialCameraPosition: _initialCameraPosition,
              markers: _markers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // Set the background color
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: Colors.black, width: 2.0), // Add black border
                  ),
                  child: Stack(
                    children: [
                      // Delete Icon
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteHistory(item['id']);
                          },
                        ),
                      ), // History Content
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.bug_report, color: primaryColor),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    formatButterflyClass(item['detection_class']),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black, // Set text color to black
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_pin, color: primaryColor),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    '${formatLocation(item['location'])}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black, // Set text color to black
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: primaryColor,
                                      size: 18,),
                                SizedBox(width: 5),
                                Text(
                                  '${item['time']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black, // Set text color to black
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
