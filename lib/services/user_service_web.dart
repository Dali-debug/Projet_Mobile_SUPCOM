import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

/// Web-compatible user service using HTTP API
class UserServiceWeb {
  static const String baseUrl = 'http://localhost:3000/api';

  // Create new user
  Future<User?> createUser({
    required String email,
    required String password,
    required String name,
    required UserType type,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'user_type': type == UserType.parent ? 'parent' : 'nursery',
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final userData = data['user'];
          return User(
            id: userData['id'],
            email: userData['email'],
            name: userData['name'],
            type: userData['type'] == 'parent'
                ? UserType.parent
                : UserType.nursery,
            phone: userData['phone'],
          );
        }
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        print('Registration failed: ${data['error']}');
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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final userData = data['user'];
          return User(
            id: userData['id'],
            email: userData['email'],
            name: userData['name'],
            type: userData['type'] == 'parent'
                ? UserType.parent
                : UserType.nursery,
            phone: userData['phone'],
          );
        }
      } else if (response.statusCode == 401) {
        print('Invalid email or password');
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
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final userData = data['user'];
          return User(
            id: userData['id'],
            email: userData['email'],
            name: userData['name'],
            type: userData['type'] == 'parent'
                ? UserType.parent
                : UserType.nursery,
            phone: userData['phone'],
          );
        }
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
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      // Note: You may want to add a DELETE endpoint in the backend
      return false;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
