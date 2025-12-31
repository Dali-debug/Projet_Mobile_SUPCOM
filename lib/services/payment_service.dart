import 'database_service.dart';

class PaymentService {
  final DatabaseService _db = DatabaseService.instance;

  // Create payment
  Future<String?> createPayment({
    required String enrollmentId,
    required String parentId,
    required double amount,
    String? paymentMethod,
    String? transactionId,
    String? description,
  }) async {
    try {
      final result = await _db.query(
        '''
        INSERT INTO payments 
        (enrollment_id, parent_id, amount, payment_method, transaction_id, description, status)
        VALUES (@enrollmentId, @parentId, @amount, @paymentMethod, @transactionId, @description, 'pending')
        RETURNING id
        ''',
        substitutionValues: {
          'enrollmentId': enrollmentId,
          'parentId': parentId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'transactionId': transactionId,
          'description': description,
        },
      );

      if (result.isNotEmpty) {
        return result.first['payments']!['id'] as String;
      }
      return null;
    } catch (e) {
      print('Error creating payment: $e');
      return null;
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus({
    required String paymentId,
    required String status, // 'pending', 'completed', 'failed', 'refunded'
  }) async {
    try {
      await _db.execute(
        '''
        UPDATE payments
        SET status = @status
        WHERE id = @paymentId
        ''',
        substitutionValues: {
          'paymentId': paymentId,
          'status': status,
        },
      );
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  // Get payments by parent
  Future<List<Map<String, dynamic>>> getPaymentsByParent(
      String parentId) async {
    try {
      final result = await _db.query(
        '''
        SELECT p.*, n.name as nursery_name, c.name as child_name
        FROM payments p
        JOIN enrollments e ON p.enrollment_id = e.id
        JOIN nurseries n ON e.nursery_id = n.id
        JOIN children c ON e.child_id = c.id
        WHERE p.parent_id = @parentId
        ORDER BY p.payment_date DESC
        ''',
        substitutionValues: {'parentId': parentId},
      );

      return result.map((row) {
        final payment = row['payments'] ?? {};
        final nursery = row['nurseries'] ?? {};
        final child = row['children'] ?? {};
        return {
          'id': payment['id'],
          'amount': payment['amount'],
          'status': payment['status'],
          'paymentDate': payment['payment_date'],
          'paymentMethod': payment['payment_method'],
          'transactionId': payment['transaction_id'],
          'description': payment['description'],
          'nurseryName': nursery['name'],
          'childName': child['name'],
        };
      }).toList();
    } catch (e) {
      print('Error getting payments: $e');
      return [];
    }
  }

  // Get payments by nursery
  Future<List<Map<String, dynamic>>> getPaymentsByNursery(
      String nurseryId) async {
    try {
      final result = await _db.query(
        '''
        SELECT p.*, u.name as parent_name, c.name as child_name
        FROM payments p
        JOIN enrollments e ON p.enrollment_id = e.id
        JOIN children c ON e.child_id = c.id
        JOIN users u ON c.parent_id = u.id
        WHERE e.nursery_id = @nurseryId
        ORDER BY p.payment_date DESC
        ''',
        substitutionValues: {'nurseryId': nurseryId},
      );

      return result.map((row) {
        final payment = row['payments'] ?? {};
        final user = row['users'] ?? {};
        final child = row['children'] ?? {};
        return {
          'id': payment['id'],
          'amount': payment['amount'],
          'status': payment['status'],
          'paymentDate': payment['payment_date'],
          'paymentMethod': payment['payment_method'],
          'parentName': user['name'],
          'childName': child['name'],
        };
      }).toList();
    } catch (e) {
      print('Error getting nursery payments: $e');
      return [];
    }
  }

  // Get payment by ID
  Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    try {
      final result = await _db.query(
        '''
        SELECT p.*, n.name as nursery_name, c.name as child_name, u.name as parent_name
        FROM payments p
        JOIN enrollments e ON p.enrollment_id = e.id
        JOIN nurseries n ON e.nursery_id = n.id
        JOIN children c ON e.child_id = c.id
        JOIN users u ON c.parent_id = u.id
        WHERE p.id = @paymentId
        ''',
        substitutionValues: {'paymentId': paymentId},
      );

      if (result.isNotEmpty) {
        final row = result.first;
        final payment = row['payments']!;
        final nursery = row['nurseries']!;
        final child = row['children']!;
        final user = row['users']!;
        return {
          'id': payment['id'],
          'amount': payment['amount'],
          'status': payment['status'],
          'paymentDate': payment['payment_date'],
          'paymentMethod': payment['payment_method'],
          'transactionId': payment['transaction_id'],
          'description': payment['description'],
          'nurseryName': nursery['name'],
          'childName': child['name'],
          'parentName': user['name'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting payment: $e');
      return null;
    }
  }
}
