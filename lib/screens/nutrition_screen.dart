import 'package:flutter/material.dart';
import 'package:foodie/common_widgets/main_button.dart';
import 'package:foodie/constants.dart';
import 'package:foodie/firebase_service.dart';
import 'package:foodie/main_layout.dart';
import 'package:foodie/models/meal_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:foodie/api_service.dart';
import 'package:location/location.dart' as loc;  // Alias added
import 'package:geocoding/geocoding.dart';

class NutritionScreen extends StatefulWidget {
  NutritionScreen({
    Key? key,
    required this.detectedFood,
    required this.mealTime,
    this.diseases,
  });

  final String detectedFood;
  final String mealTime;
  final String? diseases;

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

List<String>? diseases;

class _NutritionScreenState extends State<NutritionScreen> {
  Map<String, dynamic> nutritionDetails = {};
  Map<String, String> convertedNutritionDetails = {};

  String? currentDetectedFood;
  loc.LocationData? currentLocation;
  final location = loc.Location();  // Using the alias
  String? locationName;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    currentDetectedFood = widget.detectedFood;
    _fetchAndSetData();
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
        currentDetectedFood = response['class'];
        nutritionDetails = response['nutrition_info'];
        convertedNutritionDetails = nutritionDetails.map((key, value) => MapEntry(key, value.toString()));
      });

    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  Future<void> _fetchLocation() async {
    try {
      var _locationData = await location.getLocation();
      print("Latitude: ${_locationData.latitude}, Longitude: ${_locationData.longitude}");

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _locationData.latitude!,
        _locationData.longitude!,
      );

      if (placemarks.isEmpty) {
        print("No placemarks found for the given coordinates.");
        return;
      }

      final place = placemarks[0];
      locationName = "${place.locality}, ${place.administrativeArea}, ${place.country}";

      print("Fetched location name: $locationName");

      setState(() {
        currentLocation = _locationData;
      });

    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  String getDescription(String butterflyName) {
    if (butterflyName == 'Common_Indian_Crow') {
      return 'Adorning the skies of South Asia and Southeast Asia, the Common Indian Crow is a testament to nature’s palette and adaptability.'; // Full description
    } else if (butterflyName == 'Crimson Rose') {
      return 'The Crimson Rose,The Crimson Rose, a resplendent butterfly, seamlessly blends the drama of crimson with the depth of black.'; // Full description
    } else if (butterflyName == 'Common Mormon') {
      return 'Common Mormon, The Common Mormon, a name that belies its intricate nature, is a butterfly of multiple shades, both in color and behavior'; // Full description
    } else if (butterflyName == 'Common Mime Swallowtail') {
      return 'Common Mime Swallowtail, The world of butterflies is filled with artists and imitators, and the Common Mime Swallowtail excels at the latter.'; // Full description
    } else if (butterflyName == 'Ceylon Blue Glassy Tiger') {
      return 'Ceylon Blue Glassy Tiger, emic to the emerald isle of Sri Lanka, the Ceylon Blue Glassy Tiger is a shimmering spectacle.'; // Full description
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
                      widget.detectedFood,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

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
// Displaying the butterfly description here
                            Text(
                              getDescription(currentDetectedFood ?? ''),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...nutritionDetails.entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text('${e.key}: ${e.value}', style: TextStyle(fontSize: 16)),
                            )).toList(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    (diseases != null && widget.diseases != null && diseases!.contains(widget.diseases!))
                        ? Container(
                      width: size.width - 80,
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primaryColor,
                        border: Border.all(
                          width: 2,
                          color: Colors.red,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Warning',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'This is not good for your health,\nbecause This can be cause to your diabetes.',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                        : Container(),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            MainButton(
              size: size,
              title: 'Next',
              onTap: () {
                Meal meal = Meal(
                  type: widget.detectedFood,
                  diseases: [],
                  nutritions: convertedNutritionDetails,
                  dayName: getDayName(),
                  dateTime: DateTime.now(),
                  mealTime: widget.mealTime,
                );
                FirebaseService().addMealRecord(meal);
                Navigator.of(context).pushReplacementNamed("/nextScreenRouteName");
              },
            ),
          ],
        ),
      ),
    );
  }

  String getDayName() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE');
    final dayName = formatter.format(now);
    return dayName;
  }
}
