import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MLService {
  
  static const String diseaseApiUrl = 'https://aeshaa-disease-api.hf.space/predict'; 
  
  static const String growthApiUrl = 'https://aeshaa-tomato-growth-api.hf.space/predict';

  static Future<Map<String, dynamic>?> uploadImageForDiagnosis(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(diseaseApiUrl));
      
      var multipartFile = await http.MultipartFile.fromPath(
        'file', 
        imageFile.path,
      );
      request.files.add(multipartFile);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  static Future<Map<String, dynamic>?> uploadImageForGrowth(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(growthApiUrl));
      
      var multipartFile = await http.MultipartFile.fromPath(
        'file', 
        imageFile.path,
      );
      request.files.add(multipartFile);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}