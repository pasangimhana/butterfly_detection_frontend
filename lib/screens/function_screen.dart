import 'package:flutter/material.dart';
import 'package:foodie/common_widgets/main_button.dart';
import 'package:foodie/constants.dart';
import 'package:foodie/main_layout.dart';
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
//import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodie/screens/signin_page.dart';
import 'dart:typed_data';

class ButterflyScreen extends StatefulWidget {
  ButterflyScreen({
    Key? key,
    required this.detected,
  });
  LatLng? selectedLocation;

  final String detected;

  @override
  _ButterflyScreenState createState() => _ButterflyScreenState();
}

List<String>? diseases;

class _ButterflyScreenState extends State<ButterflyScreen> {
  Map<String, dynamic> nutritionDetails = {};
  Map<String, String> convertedNutritionDetails = {};

  final Map<String, String> butterflyImages = {
    'Common_Indian_Crow':
        "https://upload.wikimedia.org/wikipedia/commons/8/8d/Common_crow_%28Euploea_core_core%29_underside.jpg",
    'Common_Jay':
        "https://upload.wikimedia.org/wikipedia/commons/1/10/Common_Jay_%28Graphium_doson%29.jpg",
    'Common_Mime_Swallowtail':
        "https://upload.wikimedia.org/wikipedia/commons/c/c7/Open_wing_position_of_Papilio_clytia%2C_Form_Dissimilis%2C_Linnaeus%2C_1758_%E2%80%93_Common_Mime_WLB.jpg",
    'Common_Rose':
        "https://upload.wikimedia.org/wikipedia/commons/3/39/Open_wing_position_of_Pachliopta_aristolochiae_Fabricius%2C_1775_%E2%80%93_Common_Rose.jpg",
    'Cylon_Blue_Glass_Tiger':
        "https://upload.wikimedia.org/wikipedia/commons/d/d9/RadenaVulgarisM_5_1.jpg",
    'Great_eggfly':
        "https://upload.wikimedia.org/wikipedia/commons/9/93/Hypolimnas_bolina_in_Japan.jpg",
    'Lemon_Pansy':
        "https://en.wikipedia.org/wiki/File:Junonia_lemonias_-_Lemon_Pansy_25.jpg",
    'Tailed_Jay':
        "https://upload.wikimedia.org/wikipedia/commons/1/1b/Graphium_agamemnon_20131222.jpg",
    'Common Mormon':
        "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Papilio_polytes_mating_in_Kadavoor.jpg/1280px-Papilio_polytes_mating_in_Kadavoor.jpg",
   
  };
  String? currentDetected;
  loc.LocationData? currentLocation;
  final location = loc.Location();
  String? locationName;
  File? _pdfFile;
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
        convertedNutritionDetails = nutritionDetails
            .map((key, value) => MapEntry(key, value.toString()));
      });
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  Future<void> _fetchLocation() async {
    try {
      var _locationData = await location.getLocation();
      print(
          "Latitude: ${_locationData.latitude}, Longitude: ${_locationData.longitude}");

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

  Future<void> saveHistory(String location, String detectionClass, String latitude, String longitude) async {
    // final url = 'http://52.184.86.31/save-history';
    final url = '${URL.baseUrl}/save-history';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'location': location,
        'detection_class': detectionClass,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode == 200) {
      print("History saved successfully!");
    } else {
      throw Exception('Failed to save history');
    }
  }

  Future<pdfWidgets.MemoryImage> _fetchNetworkImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }
    final Uint8List uint8list = response.bodyBytes;
    return pdfWidgets.MemoryImage(uint8list);
  }

  Future<void> _saveAsPDF(String description) async {
    final pdf = pdfWidgets.Document();

    // Fetch the butterfly image
    final imageUrl = butterflyImages[currentDetected];
    final image = imageUrl != null ? await _fetchNetworkImage(imageUrl) : null;

    pdf.addPage(
      pdfWidgets.Page(
        build: (pdfWidgets.Context context) {
          return pdfWidgets.Center(
            child: pdfWidgets.Column(
              mainAxisAlignment: pdfWidgets.MainAxisAlignment.center,
              children: [
                if (image != null)
                  pdfWidgets.Image(
                      image), // Display the image if it's available
                pdfWidgets.SizedBox(height: 20),
                pdfWidgets.Text(
                  description,
                  style: pdfWidgets.TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );

    final directories =
        await getExternalStorageDirectories(type: StorageDirectory.documents);
    if (directories == null || directories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to find Documents directory.')),
      );
      return;
    }

    final documentsDirectory = directories.first;
    _pdfFile = File("${documentsDirectory.path}/butterfly_description.pdf");
    await _pdfFile!.writeAsBytes(await pdf.save());

    // Display the saved path to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to ${_pdfFile!.path}')),
    );
  }

//xml1=https://drive.google.com/file/d/1aTXT9j1VgM_ZxmQzaFhHdnSJecmgiuuj/view?usp=drive_link

  String getDescription(String butterflyName) {
    print(butterflyName);
    if (butterflyName == 'Common_Indian_Crow') {
      return 'Common Name: common indian crow,Scientific name: Euploea core,Family: Nymphalidae,Host Plant: Indian sarasaparilla (ඉරමුසු) ,  Bo Tree/ Bodhi Tree(බෝ), Wax Leaved Climber Indian ,Sarsaparilla  (වැල් රුක් අත්තන,කිරි වැල්)'; // Full description
  
    } else if (butterflyName == 'Common_Jay') {
      return 'Common Name: Tailed Jay,Scientific name: Graphium agamemnon,Family: Host Plant: Polyalthia cerasoides, Annona muricata (soursop), Xylopia championii (අතු කැටිය/දත් කැටිය).'; // Full description
   
    } else if (butterflyName == 'Common_Mime_Swallowtail') {
      return 'Scientific Name: Papilio clytia,Host Plant:  Neolitsea cassia,  Litsea longifolia';
   
    } else if (butterflyName == 'Common_Rose') {
      return 'Scientific Name: Pachliopta aristolochiae,Family: Papilionidae,Host Plant: The Indian Birthwort (සප්සඳ)'; // Full description
   
    } else if (butterflyName == 'Cylon_Blue_Glass_Tiger') {
      return 'Common Name: cylon blue glass tiger,Scientific Name: Ideopsis similis,Host Plant:Tylophora indica.';
   
      }else if (butterflyName == 'Great_eggfly') {
      return 'Common Name: Great Eggfly,Scientific name: Hypolimnas bolina,Family: Nymphalidae,Host Plant: Common purslane'; 
   
       } else if (butterflyName == 'Lemon_Pansy') {
      return 'Common Name: Lemon Pansy,Scientific name: Junonia lemonias,Host Plant: Barleria prionitis (Porcupine flower), Hygrophila schulli (Long leaved barleria Marsh Barbel), Lindernia rotundifolia (Baby Tears)';
    
      }else if (butterflyName == 'Tailed_Jayr') {
      return 'Common Name: Tailed Jay,Scientific name: Graphium agamemnon,Host Plant: Polyalthia cerasoides, Annona muricata (soursop), Xylopia championii (අතු කැටිය/දත් කැටිය)';
      // Full description
    }
    else if (butterflyName == "Common Mormon") {
      return 'Common Name: Common Mormon,Scientific name: Papilio polytes,Family: Papilionidae,Host Plant: Citrus aurantifolia (lime), Citrus limon lemon)';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    Color primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Butterfly Detection'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
            child: Text('logout', style: TextStyle(color: Color.fromARGB(255, 92, 17, 17))),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      widget.detected,
                      style: theme.textTheme.headline5?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (currentDetected != null)
                      Image.network(
                        butterflyImages[currentDetected] ?? '',
                        width: size.width - 40,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    Container(
                      width: size.width,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: primaryColor.withOpacity(0.1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Butterfly information',
                            style: theme.textTheme.subtitle1?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (currentLocation != null) ...[
                            Text(
                              'Location:',
                              style: theme.textTheme.bodyText2?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Location: ${locationName ?? 'Fetching location...'}',
                              style: theme.textTheme.bodyText2?.copyWith(
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Text(
                            'Description:',
                            style: theme.textTheme.bodyText2?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            getDescription(currentDetected ?? ''),
                            style: theme.textTheme.bodyText2?.copyWith(
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _saveAsPDF(
                                getDescription(currentDetected ?? ''),
                              );
                            },
                            child: Text("Save Description as PDF"),
                            style: ElevatedButton.styleFrom(
                              primary: primaryColor,
                               onPrimary: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...nutritionDetails.entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '${e.key}: ${e.value}',
                                style: TextStyle(
                                    fontSize: 16, color: primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        saveHistory(locationName ?? '', currentDetected ?? '', currentLocation!.latitude.toString(), currentLocation!.longitude.toString());
                      },
                      child: Text("Save History"),
                      style: ElevatedButton.styleFrom(
                        primary: primaryColor,
                         onPrimary: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final LatLng? returnedLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LocationScreen()),
                        );

                        if (returnedLocation != null) {
                          final address = await getPlaceAddress(
                              returnedLocation.latitude,
                              returnedLocation.longitude);

                          setState(() {
                            widget.selectedLocation = returnedLocation;
                            locationName = address ?? "Unknown address";
                          });
                        }
                      },
                      child: Text("Add location"),
                      style: ElevatedButton.styleFrom(
                        primary: primaryColor,
                         onPrimary: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_pdfFile != null && _pdfFile!.existsSync()) {
                          Printing.layoutPdf(
                            onLayout: (PdfPageFormat format) async =>
                                _pdfFile!.readAsBytesSync(),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please save the PDF first.'),
                            ),
                          );
                        }
                      },
                      child: Text("Open PDF"),
                      style: ElevatedButton.styleFrom(
                        primary: primaryColor,
                         onPrimary: Colors.white,
                      ),
                    ),
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
