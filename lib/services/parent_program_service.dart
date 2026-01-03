import 'dart:convert';
import 'package:http/http.dart' as http;

class ParentProgramService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Get today's program for the nursery where the parent's child is enrolled
  static Future<Map<String, dynamic>> getTodayProgram(String parentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parents/$parentId/today-program'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'program': List<Map<String, dynamic>>.from(data['program'] ?? []),
          'nurseryName': data['nurseryName'],
        };
      }
      return {'success': false, 'error': 'Failed to load program'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get recent reviews for the nursery where the parent's child is enrolled
  static Future<Map<String, dynamic>> getNurseryRecentReviews(
      String parentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parents/$parentId/nursery-reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'reviews': List<Map<String, dynamic>>.from(data['reviews'] ?? []),
        };
      }
      return {'success': false, 'error': 'Failed to load reviews'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
