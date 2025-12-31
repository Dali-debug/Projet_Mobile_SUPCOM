import 'database_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ConversationService {
  final DatabaseService _db = DatabaseService.instance;

  // Create or get conversation
  Future<String?> getOrCreateConversation({
    required String parentId,
    required String nurseryId,
  }) async {
    try {
      // Check if conversation exists
      final existing = await _db.query(
        '''
        SELECT id FROM conversations
        WHERE parent_id = @parentId AND nursery_id = @nurseryId
        ''',
        substitutionValues: {
          'parentId': parentId,
          'nurseryId': nurseryId,
        },
      );

      if (existing.isNotEmpty) {
        return existing.first['conversations']!['id'] as String;
      }

      // Create new conversation
      final result = await _db.query(
        '''
        INSERT INTO conversations (parent_id, nursery_id)
        VALUES (@parentId, @nurseryId)
        RETURNING id
        ''',
        substitutionValues: {
          'parentId': parentId,
          'nurseryId': nurseryId,
        },
      );

      if (result.isNotEmpty) {
        return result.first['conversations']!['id'] as String;
      }
      return null;
    } catch (e) {
      print('Error creating conversation: $e');
      return null;
    }
  }

  // Get conversations by user
  Future<List<Conversation>> getConversationsByUser(String userId) async {
    try {
      final result = await _db.query(
        '''
        SELECT c.*, 
               n.name as nursery_name, n.photo_url as nursery_photo,
               u.name as parent_name
        FROM conversations c
        LEFT JOIN nurseries n ON c.nursery_id = n.id
        LEFT JOIN users u ON c.parent_id = u.id
        WHERE c.parent_id = @userId OR 
              c.nursery_id IN (SELECT id FROM nurseries WHERE owner_id = @userId)
        ORDER BY c.last_message_at DESC
        ''',
        substitutionValues: {'userId': userId},
      );

      List<Conversation> conversations = [];
      for (var row in result) {
        final conv = row['conversations']!;
        final conversationId = conv['id'] as String;

        // Get messages for this conversation
        final messages = await getMessagesByConversation(conversationId);

        // Count unread messages
        final unreadCount = await getUnreadMessageCount(conversationId, userId);

        conversations.add(Conversation(
          id: conversationId,
          parentId: conv['parent_id'] as String,
          directeurId:
              conv['nursery_id'] as String, // Using nursery_id as directeurId
          garderieId: conv['nursery_id'] as String,
          messages: messages,
          derniereMiseAJour: DateTime.parse(conv['last_message_at'].toString()),
          messagesNonLus: unreadCount,
        ));
      }

      return conversations;
    } catch (e) {
      print('Error getting conversations: $e');
      return [];
    }
  }

  // Send message
  Future<Message?> sendMessage({
    required String conversationId,
    required String senderId,
    required String recipientId,
    required String content,
  }) async {
    try {
      final result = await _db.query(
        '''
        INSERT INTO messages (conversation_id, sender_id, recipient_id, content)
        VALUES (@conversationId, @senderId, @recipientId, @content)
        RETURNING *
        ''',
        substitutionValues: {
          'conversationId': conversationId,
          'senderId': senderId,
          'recipientId': recipientId,
          'content': content,
        },
      );

      if (result.isNotEmpty) {
        final row = result.first['messages']!;
        return Message(
          id: row['id'] as String,
          expediteurId: row['sender_id'] as String,
          destinataireId: row['recipient_id'] as String,
          contenu: row['content'] as String,
          dateEnvoi: DateTime.parse(row['sent_at'].toString()),
          estLu: row['is_read'] as bool,
        );
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Get messages by conversation
  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    try {
      final result = await _db.query(
        '''
        SELECT * FROM messages
        WHERE conversation_id = @conversationId
        ORDER BY sent_at ASC
        ''',
        substitutionValues: {'conversationId': conversationId},
      );

      return result.map((row) {
        final msg = row['messages']!;
        return Message(
          id: msg['id'] as String,
          expediteurId: msg['sender_id'] as String,
          destinataireId: msg['recipient_id'] as String,
          contenu: msg['content'] as String,
          dateEnvoi: DateTime.parse(msg['sent_at'].toString()),
          estLu: msg['is_read'] as bool,
        );
      }).toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _db.execute(
        '''
        UPDATE messages
        SET is_read = true
        WHERE conversation_id = @conversationId 
          AND recipient_id = @userId
          AND is_read = false
        ''',
        substitutionValues: {
          'conversationId': conversationId,
          'userId': userId,
        },
      );
      return true;
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount(
      String conversationId, String userId) async {
    try {
      final result = await _db.query(
        '''
        SELECT COUNT(*) as count FROM messages
        WHERE conversation_id = @conversationId 
          AND recipient_id = @userId
          AND is_read = false
        ''',
        substitutionValues: {
          'conversationId': conversationId,
          'userId': userId,
        },
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

  // Delete conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _db.execute(
        'DELETE FROM conversations WHERE id = @conversationId',
        substitutionValues: {'conversationId': conversationId},
      );
      return true;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }
}
