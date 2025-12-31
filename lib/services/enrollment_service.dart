import 'database_service.dart';

class EnrollmentService {
  final DatabaseService _db = DatabaseService.instance;

  // Create enrollment
  Future<String?> createEnrollment({
    required String childId,
    required String nurseryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _db.query(
        '''
        INSERT INTO enrollments (child_id, nursery_id, start_date, end_date, status)
        VALUES (@childId, @nurseryId, @startDate, @endDate, 'pending')
        RETURNING id
        ''',
        substitutionValues: {
          'childId': childId,
          'nurseryId': nurseryId,
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
        },
      );

      if (result.isNotEmpty) {
        return result.first['enrollments']!['id'] as String;
      }
      return null;
    } catch (e) {
      print('Error creating enrollment: $e');
      return null;
    }
  }

  // Update enrollment status
  Future<bool> updateEnrollmentStatus({
    required String enrollmentId,
    required String status, // 'pending', 'active', 'completed', 'cancelled'
  }) async {
    try {
      await _db.execute(
        '''
        UPDATE enrollments
        SET status = @status, updated_at = CURRENT_TIMESTAMP
        WHERE id = @enrollmentId
        ''',
        substitutionValues: {
          'enrollmentId': enrollmentId,
          'status': status,
        },
      );

      // Update nursery available spots
      if (status == 'active') {
        await _db.execute(
          '''
          UPDATE nurseries
          SET available_spots = available_spots - 1
          WHERE id = (SELECT nursery_id FROM enrollments WHERE id = @enrollmentId)
          ''',
          substitutionValues: {'enrollmentId': enrollmentId},
        );
      } else if (status == 'cancelled' || status == 'completed') {
        await _db.execute(
          '''
          UPDATE nurseries
          SET available_spots = available_spots + 1
          WHERE id = (SELECT nursery_id FROM enrollments WHERE id = @enrollmentId)
          ''',
          substitutionValues: {'enrollmentId': enrollmentId},
        );
      }

      return true;
    } catch (e) {
      print('Error updating enrollment status: $e');
      return false;
    }
  }

  // Get enrollments by child
  Future<List<Map<String, dynamic>>> getEnrollmentsByChild(
      String childId) async {
    try {
      final result = await _db.query(
        '''
        SELECT e.*, n.name as nursery_name, n.address, n.photo_url
        FROM enrollments e
        JOIN nurseries n ON e.nursery_id = n.id
        WHERE e.child_id = @childId
        ORDER BY e.enrollment_date DESC
        ''',
        substitutionValues: {'childId': childId},
      );

      return result.map((row) {
        final enrollment = row['enrollments'] ?? {};
        final nursery = row['nurseries'] ?? {};
        return {
          'id': enrollment['id'],
          'status': enrollment['status'],
          'enrollmentDate': enrollment['enrollment_date'],
          'startDate': enrollment['start_date'],
          'endDate': enrollment['end_date'],
          'nurseryId': enrollment['nursery_id'],
          'nurseryName': nursery['name'],
          'address': nursery['address'],
          'photoUrl': nursery['photo_url'],
        };
      }).toList();
    } catch (e) {
      print('Error getting enrollments: $e');
      return [];
    }
  }

  // Get enrollments by nursery
  Future<List<Map<String, dynamic>>> getEnrollmentsByNursery(
    String nurseryId, {
    String? status,
  }) async {
    try {
      String whereClause = 'WHERE e.nursery_id = @nurseryId';
      Map<String, dynamic> values = {'nurseryId': nurseryId};

      if (status != null) {
        whereClause += ' AND e.status = @status';
        values['status'] = status;
      }

      final result = await _db.query(
        '''
        SELECT e.*, c.name as child_name, c.age, c.photo_url, u.name as parent_name, u.phone
        FROM enrollments e
        JOIN children c ON e.child_id = c.id
        JOIN users u ON c.parent_id = u.id
        $whereClause
        ORDER BY e.enrollment_date DESC
        ''',
        substitutionValues: values,
      );

      return result.map((row) {
        final enrollment = row['enrollments'] ?? {};
        final child = row['children'] ?? {};
        final user = row['users'] ?? {};
        return {
          'id': enrollment['id'],
          'status': enrollment['status'],
          'enrollmentDate': enrollment['enrollment_date'],
          'childId': enrollment['child_id'],
          'childName': child['name'],
          'childAge': child['age'],
          'childPhoto': child['photo_url'],
          'parentName': user['name'],
          'parentPhone': user['phone'],
        };
      }).toList();
    } catch (e) {
      print('Error getting nursery enrollments: $e');
      return [];
    }
  }

  // Delete enrollment
  Future<bool> deleteEnrollment(String enrollmentId) async {
    try {
      await _db.execute(
        'DELETE FROM enrollments WHERE id = @enrollmentId',
        substitutionValues: {'enrollmentId': enrollmentId},
      );
      return true;
    } catch (e) {
      print('Error deleting enrollment: $e');
      return false;
    }
  }
}
