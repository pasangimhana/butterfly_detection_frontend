import 'package:flutter/material.dart';
import 'package:foodie/common_widgets/main_button.dart';
import 'package:foodie/constants.dart';
import 'package:foodie/main_layout.dart';
import 'package:foodie/models/meal_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:foodie/api_service.dart';
import 'package:foodie/screens/location.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class NutritionScreen extends StatefulWidget {
  NutritionScreen({
    Key? key,
    required this.detected,
    required this.mealTime,
    this.diseases,
  });
  LatLng? selectedLocation;

  final String detected;
  final String mealTime;
  final String? diseases;

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

List<String>? diseases;

class _NutritionScreenState extends State<NutritionScreen> {
  Map<String, dynamic> nutritionDetails = {};
  Map<String, String> convertedNutritionDetails = {};
  
  final Map<String, String> butterflyImages = {
    'Common_Indian_Crow': "https://th.bing.com/th/id/OIP.dkegJ5-d-WNNrBqwvPWHigHaFj?pid=ImgDet&rs=1",
    'Crimson Rose': "https://dmc.dilmahtea.com/web-space/dmc/butterflies/76546f9a641ede2beab506b96df1688d889e629a/148938871051024.png",
    'Common Mormon': "https://upload.wikimedia.org/wikipedia/commons/8/8d/Papilio_polytes_mating_in_Kadavoor.jpg",
    'Common Mime Swallowtail': "https://upload.wikimedia.org/wikipedia/commons/c/c7/Open_wing_position_of_Papilio_clytia%2C_Form_Dissimilis%2C_Linnaeus%2C_1758_%E2%80%93_Common_Mime_WLB.jpg",
    'Ceylon Blue Glassy Tiger': "https://upload.wikimedia.org/wikipedia/commons/6/63/Ceylon_Blue_Glassy_Tiger_Ideopsis_similis_%E7%90%89%E7%90%83%E6%B5%85%E8%91%B1%E6%96%91%28%E3%83%AA%E3%83%A5%E3%82%A6%E3%82%AD%E3%83%A5%E3%82%A6%E3%82%A2%E3%82%B5%E3%82%AE%E3%83%9E%E3%83%80%E3%83%A9%29.jpg",
  };
  String? currentDetected;
  loc.LocationData? currentLocation;
  final location = loc.Location();
  String? locationName;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    currentDetected = widget.detected;
    _fetchAndSetData();
  }


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


  Future<void> _initializeLocation() async {
    bool? serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == null || !serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (serviceEnabled == null || !serviceEnabled) return;
    }

    loc.PermissionStatus? permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _fetchLocation();
  }

  Future<void> _fetchAndSetData() async {
    File myImage = File('path_to_your_image.jpg');

    try {
      Map<String, dynamic> response = await ApiService().uploadImage(myImage);

      setState(() {
        currentDetected = response['class'];
        // nutritionDetails = response['nutrition_info'];
        convertedNutritionDetails = nutritionDetails.map((key, value) =>
            MapEntry(key, value.toString()));
      });
    } catch (error) {
      print("Error fetching data: $error");
    }
  }






  Future<void> _fetchLocation() async {
    try {
      var _locationData = await location.getLocation();
      print("Latitude: ${_locationData.latitude}, Longitude: ${_locationData
          .longitude}");

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _locationData.latitude!,
        _locationData.longitude!,
      );

      if (placemarks.isEmpty) {
        print("No placemarks found for the given coordinates.");
        return;
      }

      final place = placemarks[0];
      locationName =
      "${place.locality}, ${place.administrativeArea}, ${place.country}";

      print("Fetched location name: $locationName");

      setState(() {
        currentLocation = _locationData;
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> saveHistory(String location, String detectionClass) async {
    final url = 'https://butterfly-detection.onrender.com/save-history';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'location': location,
        'detection_class': detectionClass,
      }),
    );

    if (response.statusCode == 200) {
      print("History saved successfully!");
    } else {
      throw Exception('Failed to save history');
    }
  }



  Future<void> _saveAsPDF(String description) async {
    final pdf = pdfWidgets.Document();

    pdf.addPage(
      pdfWidgets.Page(
        build: (pdfWidgets.Context context) => pdfWidgets.Center(
          child: pdfWidgets.Text(
            description,
            style: pdfWidgets.TextStyle(fontSize: 14),
          ),
        ),
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/butterfly_description.pdf");
    await file.writeAsBytes(await pdf.save());

    // Optional: Display a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to ${file.path}')),
    );
  }





  String getDescription(String butterflyName) {
    if (butterflyName == 'Common_Indian_Crow') {
      return 'Common Name: common indian crow,Scientific name: Euploea core,Family: Nymphalidae,Host Plant: Indian sarasaparilla (ඉරමුසු) ,  Bo Tree/ Bodhi Tree(බෝ), Wax Leaved Climber Indian ,Sarsaparilla  (වැල් රුක් අත්තන,කිරි වැල්)'; // Full description
    } else if (butterflyName == 'Crimson Rose') {
      return 'Scientific Name: Pachliopta aristolochiae,Family: Papilionidae,Host Plant: The Indian Birthwort (සප්සඳ),.'; // Full description
    } else if (butterflyName == 'Common Mormon') {
      return 'Scientific Name: Papilio polytes,Host Plant: Winged Naringi (තුම්පත් කුරුඳු) ,Curry Leaf Tree (කරපිංචා) , orangeberry/ gin berry (දොඩම් පනා)';
    } else if (butterflyName == 'Common Mime Swallowtail') {
      return 'Scientific Name: Papilio clytia,Host Plant:  Neolitsea cassia,  Litsea longifolia,'; // Full description
    } else if (butterflyName == 'Ceylon Blue Glassy Tiger') {
      return 'Scientific Name: Ideopsis similis,Host Plant:Tylophora indica.'; // Full description
    }
    else {
      return '';
    }
  }



   @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MainLayout(
      title: 'Butterfly detection',
      customBody: Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      widget.detected,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (currentDetected != null)
                      Image.network(butterflyImages[currentDetected] ?? ''),

                    Container(
                      width: size.width - 80,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primaryColor.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Butterfly information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (currentLocation != null) ...[
                              Text(
                                'Location:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Location: ${locationName ?? 'Fetching location...'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Text(
                              'Description:',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              getDescription(currentDetected ?? ''),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _saveAsPDF(getDescription(currentDetected ?? ''));
                              },
                              child: Text("Save Description as PDF"),
                            ),
                            const SizedBox(height: 20),
                            ...nutritionDetails.entries.map((e) =>
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text('${e.key}: ${e.value}', style: TextStyle(fontSize: 16)),
                                )).toList(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        saveHistory(locationName ?? '', currentDetected ?? '');
                      },
                      child: Text("Save History"),
                    ),
                    const SizedBox(height: 10),
    ElevatedButton(
  onPressed: () async {
    final LatLng? returnedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationScreen()),
    );

    if (returnedLocation != null) {
      final address = await getPlaceAddress(returnedLocation.latitude, returnedLocation.longitude);

      setState(() {
        widget.selectedLocation = returnedLocation;
        locationName = address ?? "Unknown address";
      });
    }
  },
  child: Text("Add location"),
),

              // if (widget.selectedLocation != null)
              //   Text("Selected Location: Lat: ${widget.selectedLocation!.latitude}, Lng: ${widget.selectedLocation!.longitude}"),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}