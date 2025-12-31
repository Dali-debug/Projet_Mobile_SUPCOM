import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'database_service.dart';
import '../models/user.dart';

class UserService {
  final DatabaseService _db = DatabaseService.instance;

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Create new user
  Future<User?> createUser({
    required String email,
    required String password,
    required String name,
    required UserType type,
    String? phone,
  }) async {
    try {
      final passwordHash = _hashPassword(password);

      final result = await _db.query(
        '''
        INSERT INTO users (email, password_hash, user_type, name, phone)
        VALUES (@email, @passwordHash, @type, @name, @phone)
        RETURNING id, email, user_type, name, phone
        ''',
        substitutionValues: {
          'email': email,
          'passwordHash': passwordHash,
          'type': type == UserType.parent ? 'parent' : 'nursery',
          'name': name,
          'phone': phone,
        },
      );

      if (result.isNotEmpty) {
        final row = result.first['users']!;
        return User(
          id: row['id'] as String,
          email: row['email'] as String,
          name: row['name'] as String,
          type:
              row['user_type'] == 'parent' ? UserType.parent : UserType.nursery,
          phone: row['phone'] as String?,
        );
      }
      return null;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      final passwordHash = _hashPassword(password);

      final result = await _db.query(
        '''
        SELECT id, email, user_type, name, phone
        FROM users
        WHERE email = @email AND password_hash = @passwordHash
        ''',
        substitutionValues: {
          'email': email,
          'passwordHash': passwordHash,
        },
      );

      if (result.isNotEmpty) {
        final row = result.first['users']!;
        return User(
          id: row['id'] as String,
          email: row['email'] as String,
          name: row['name'] as String,
          type:
              row['user_type'] == 'parent' ? UserType.parent : UserType.nursery,
          phone: row['phone'] as String?,
        );
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final result = await _db.query(
        '''
        SELECT id, email, user_type, name, phone
        FROM users
        WHERE id = @userId
        ''',
        substitutionValues: {'userId': userId},
      );

      if (result.isNotEmpty) {
        final row = result.first['users']!;
        return User(
          id: row['id'] as String,
          email: row['email'] as String,
          name: row['name'] as String,
          type:
              row['user_type'] == 'parent' ? UserType.parent : UserType.nursery,
          phone: row['phone'] as String?,
        );
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUser({
    required String userId,
    String? name,
    String? phone,
  }) async {
    try {
      await _db.execute(
        '''
        UPDATE users
        SET name = COALESCE(@name, name),
            phone = COALESCE(@phone, phone),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = @userId
        ''',
        substitutionValues: {
          'userId': userId,
          'name': name,
          'phone': phone,
        },
      );
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      await _db.execute(
        'DELETE FROM users WHERE id = @userId',
        substitutionValues: {'userId': userId},
      );
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
