import 'database_service.dart';

class NotificationService {
  final DatabaseService _db = DatabaseService.instance;

  // Create notification
  Future<String?> createNotification({
    required String userId,
    required String type,
    required String message,
    String? title,
    String? relatedId,
  }) async {
    try {
      final result = await _db.query(
        '''
        INSERT INTO notifications (user_id, type, title, message, related_id)
        VALUES (@userId, @type, @title, @message, @relatedId)
        RETURNING id
        ''',
        substitutionValues: {
          'userId': userId,
          'type': type,
          'title': title,
          'message': message,
          'relatedId': relatedId,
        },
      );

      if (result.isNotEmpty) {
        return result.first['notifications']!['id'] as String;
      }
      return null;
    } catch (e) {
      print('Error creating notification: $e');
      return null;
    }
  }

  // Get notifications by user
  Future<List<Map<String, dynamic>>> getNotificationsByUser(
    String userId, {
    bool? isRead,
  }) async {
    try {
      String whereClause = 'WHERE user_id = @userId';
      Map<String, dynamic> values = {'userId': userId};

      if (isRead != null) {
        whereClause += ' AND is_read = @isRead';
        values['isRead'] = isRead;
      }

      final result = await _db.query(
        '''
        SELECT * FROM notifications
        $whereClause
        ORDER BY sent_at DESC
        ''',
        substitutionValues: values,
      );

      return result.map((row) {
        final notif = row['notifications']!;
        return {
          'id': notif['id'],
          'type': notif['type'],
          'title': notif['title'],
          'message': notif['message'],
          'isRead': notif['is_read'],
          'relatedId': notif['related_id'],
          'sentAt': notif['sent_at'],
        };
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _db.execute(
        'UPDATE notifications SET is_read = true WHERE id = @notificationId',
        substitutionValues: {'notificationId': notificationId},
      );
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all as read for user
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _db.execute(
        'UPDATE notifications SET is_read = true WHERE user_id = @userId',
        substitutionValues: {'userId': userId},
      );
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final result = await _db.query(
        '''
        SELECT COUNT(*) as count FROM notifications
        WHERE user_id = @userId AND is_read = false
        ''',
        substitutionValues: {'userId': userId},
      );

      if (result.isNotEmpty) {
        return result.first['']!['count'] as int;
      }
      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _db.execute(
        'DELETE FROM notifications WHERE id = @notificationId',
        substitutionValues: {'notificationId': notificationId},
      );
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Delete all read notifications
  Future<bool> deleteAllRead(String userId) async {
    try {
      await _db.execute(
        'DELETE FROM notifications WHERE user_id = @userId AND is_read = true',
        substitutionValues: {'userId': userId},
      );
      return true;
    } catch (e) {
      print('Error deleting read notifications: $e');
      return false;
    }
  }
}
