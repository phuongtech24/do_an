import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator connecting to localhost
  // Or localhost for Flutter Web
  static const String baseUrl = 'http://localhost:8080/api/v1';

  static Future<List<Map<String, dynamic>>> getPatientRoadmap(String patientId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/patients/$patientId/roadmap'));
      
      if (response.statusCode == 200) {
        // Decode UTF-8 to handle Vietnamese text properly
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load roadmap: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error: $e');
      throw Exception('Network Error: $e');
    }
  }
}
