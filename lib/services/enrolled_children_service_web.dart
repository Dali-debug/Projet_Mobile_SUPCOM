import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service to manage enrolled children and parents for nursery dashboard
class EnrolledChildrenService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Fetch all parents and their enrolled children for a nursery
  /// Returns a map with parents and their children grouped together
  static Future<Map<String, dynamic>> getEnrolledChildren(String nurseryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nurseries/$nurseryId/enrolled-children'),
      );

      print('📋 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'nurseryId': data['nurseryId'],
            'totalParents': data['totalParents'] ?? 0,
            'totalChildren': data['totalChildren'] ?? 0,
            'parents': List<Map<String, dynamic>>.from(
              (data['parents'] ?? []).map((parent) => {
                'parentId': parent['parentId'],
                'parentName': parent['parentName'],
                'parentEmail': parent['parentEmail'],
                'parentPhone': parent['parentPhone'],
                'children': List<Map<String, dynamic>>.from(
                  (parent['children'] ?? []).map((child) => {
                    'childId': child['childId'],
                    'childName': child['childName'],
                    'age': child['age'],
                    'birthDate': child['birthDate'],
                    'enrollmentId': child['enrollmentId'],
                    'enrollmentStatus': child['enrollmentStatus'],
                    'startDate': child['startDate'],
                    'enrollmentDate': child['enrollmentDate'],
                  })
                )
              })
            )
          };
        }
      }

      return {
        'success': false,
        'error': 'Failed to fetch enrolled children'
      };
    } catch (e) {
      print('❌ Error fetching enrolled children: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  /// Get a summary of enrolled children count
  static Future<Map<String, dynamic>> getEnrolledChildrenSummary(String nurseryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nurseries/$nurseryId/enrolled-children'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'totalParents': data['totalParents'] ?? 0,
            'totalChildren': data['totalChildren'] ?? 0,
          };
        }
      }

      return {
        'success': false,
        'error': 'Failed to fetch summary'
      };
    } catch (e) {
      print('❌ Error fetching summary: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
}
