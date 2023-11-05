// api_service.dart

import 'dart:io';
import 'package:dio/dio.dart';

import 'constants.dart';

class ApiService {
  //static const String _baseUrl = "https://food-detection-nutrition-app.onrender.com";

  static const String _baseUrl = URL.baseUrl; // For Android emulator
  // static const String _baseUrl = "http://52.184.86.31"; // For Android emulator
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> uploadImage(File image) async {
    String endPoint = "/predict";
    String fileName = _getFileNameFromFile(image);
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: fileName),
    });

    try {
      Response response = await _dio.post(
        "$_baseUrl$endPoint",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to upload image: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }

  String _getFileNameFromFile(File file) {
    String filePath = file.path;
    List<String> parts = filePath.split('/');
    return parts.last;
  }
}
