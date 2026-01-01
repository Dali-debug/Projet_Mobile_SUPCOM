import 'dart:convert';
import 'package:http/http.dart' as http;

class EnrollmentServiceWeb {
  static const String baseUrl = 'http://localhost:3000/api';

  // Create enrollment
  Future<Map<String, dynamic>?> createEnrollment({
    required String childName,
    required String birthDate,
    required String parentName,
    required String parentPhone,
    required String nurseryId,
    required String startDate,
    String? notes,
    String? parentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enrollments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'childName': childName,
          'birthDate': birthDate,
          'parentName': parentName,
          'parentPhone': parentPhone,
          'nurseryId': nurseryId,
          'startDate': startDate,
          'notes': notes,
          'parentId': parentId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['enrollment'];
        }
      }
      return null;
    } catch (e) {
      print('Error creating enrollment: $e');
      return null;
    }
  }

  // Get enrollments by nursery
  Future<List<Map<String, dynamic>>> getEnrollmentsByNursery(
      String nurseryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/enrollments/nursery/$nurseryId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['enrollments']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching enrollments: $e');
      return [];
    }
  }

  // Get all enrollments
  Future<List<Map<String, dynamic>>> getAllEnrollments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/enrollments'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['enrollments']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching all enrollments: $e');
      return [];
    }
  }

  // Update enrollment status (accept/reject)
  Future<bool> updateEnrollmentStatus(
      String enrollmentId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/enrollments/$enrollmentId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating enrollment status: $e');
      return false;
    }
  }
}
