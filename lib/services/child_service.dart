import 'database_service.dart';
import '../models/child.dart';

class ChildService {
  final DatabaseService _db = DatabaseService.instance;

  // Create new child
  Future<Child?> createChild({
    required String parentId,
    required String name,
    required int age,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? medicalNotes,
  }) async {
    try {
      final result = await _db.query(
        '''
        INSERT INTO children (parent_id, name, age, date_of_birth, photo_url, medical_notes)
        VALUES (@parentId, @name, @age, @dateOfBirth, @photoUrl, @medicalNotes)
        RETURNING *
        ''',
        substitutionValues: {
          'parentId': parentId,
          'name': name,
          'age': age,
          'dateOfBirth': dateOfBirth?.toIso8601String(),
          'photoUrl': photoUrl,
          'medicalNotes': medicalNotes,
        },
      );

      if (result.isNotEmpty) {
        final row = result.first['children']!;
        return Child(
          id: row['id'] as String,
          name: row['name'] as String,
          age: row['age'] as int,
          photo: row['photo_url'] as String?,
          nurseryId: null,
        );
      }
      return null;
    } catch (e) {
      print('Error creating child: $e');
      return null;
    }
  }

  // Get child by ID
  Future<Child?> getChildById(String childId) async {
    try {
      final result = await _db.query(
        'SELECT * FROM children WHERE id = @childId',
        substitutionValues: {'childId': childId},
      );

      if (result.isNotEmpty) {
        final row = result.first['children']!;

        // Get current nursery enrollment
        final enrollmentResult = await _db.query(
          '''
          SELECT nursery_id FROM enrollments 
          WHERE child_id = @childId AND status = 'active'
          LIMIT 1
          ''',
          substitutionValues: {'childId': childId},
        );

        String? nurseryId;
        if (enrollmentResult.isNotEmpty) {
          nurseryId =
              enrollmentResult.first['enrollments']!['nursery_id'] as String?;
        }

        return Child(
          id: row['id'] as String,
          name: row['name'] as String,
          age: row['age'] as int,
          photo: row['photo_url'] as String?,
          nurseryId: nurseryId,
        );
      }
      return null;
    } catch (e) {
      print('Error getting child: $e');
      return null;
    }
  }

  // Get all children by parent
  Future<List<Child>> getChildrenByParent(String parentId) async {
    try {
      final result = await _db.query(
        'SELECT id FROM children WHERE parent_id = @parentId',
        substitutionValues: {'parentId': parentId},
      );

      List<Child> children = [];
      for (var row in result) {
        final child = await getChildById(row['children']!['id'] as String);
        if (child != null) children.add(child);
      }

      return children;
    } catch (e) {
      print('Error getting children: $e');
      return [];
    }
  }

  // Update child
  Future<bool> updateChild({
    required String childId,
    String? name,
    int? age,
    String? photoUrl,
    String? medicalNotes,
  }) async {
    try {
      await _db.execute(
        '''
        UPDATE children
        SET name = COALESCE(@name, name),
            age = COALESCE(@age, age),
            photo_url = COALESCE(@photoUrl, photo_url),
            medical_notes = COALESCE(@medicalNotes, medical_notes),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = @childId
        ''',
        substitutionValues: {
          'childId': childId,
          'name': name,
          'age': age,
          'photoUrl': photoUrl,
          'medicalNotes': medicalNotes,
        },
      );
      return true;
    } catch (e) {
      print('Error updating child: $e');
      return false;
    }
  }

  // Delete child
  Future<bool> deleteChild(String childId) async {
    try {
      await _db.execute(
        'DELETE FROM children WHERE id = @childId',
        substitutionValues: {'childId': childId},
      );
      return true;
    } catch (e) {
      print('Error deleting child: $e');
      return false;
    }
  }
}
