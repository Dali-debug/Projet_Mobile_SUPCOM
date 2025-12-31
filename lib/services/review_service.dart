import 'database_service.dart';
import '../models/review.dart';

class ReviewService {
  final DatabaseService _db = DatabaseService.instance;

  // Create review
  Future<Review?> createReview({
    required String nurseryId,
    required String parentId,
    required double rating,
    required String comment,
  }) async {
    try {
      final result = await _db.query(
        '''
        INSERT INTO reviews (nursery_id, parent_id, rating, comment)
        VALUES (@nurseryId, @parentId, @rating, @comment)
        RETURNING r.*, u.name as parent_name
        FROM reviews r
        JOIN users u ON r.parent_id = u.id
        WHERE r.id = (SELECT id FROM reviews ORDER BY created_at DESC LIMIT 1)
        ''',
        substitutionValues: {
          'nurseryId': nurseryId,
          'parentId': parentId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (result.isNotEmpty) {
        final row = result.first;
        final review = row['reviews']!;
        final user = row['users']!;
        return Review(
          id: review['id'] as String,
          parentName: user['name'] as String,
          rating: (review['rating'] as num).toDouble(),
          comment: review['comment'] as String,
          date: review['created_at'].toString(),
        );
      }
      return null;
    } catch (e) {
      print('Error creating review: $e');
      return null;
    }
  }

  // Get reviews by nursery
  Future<List<Review>> getReviewsByNursery(String nurseryId) async {
    try {
      final result = await _db.query(
        '''
        SELECT r.*, u.name as parent_name
        FROM reviews r
        JOIN users u ON r.parent_id = u.id
        WHERE r.nursery_id = @nurseryId
        ORDER BY r.created_at DESC
        ''',
        substitutionValues: {'nurseryId': nurseryId},
      );

      return result.map((row) {
        final review = row['reviews']!;
        final user = row['users']!;
        return Review(
          id: review['id'] as String,
          parentName: user['name'] as String,
          rating: (review['rating'] as num).toDouble(),
          comment: review['comment'] as String,
          date: review['created_at'].toString(),
        );
      }).toList();
    } catch (e) {
      print('Error getting reviews: $e');
      return [];
    }
  }

  // Get reviews by parent
  Future<List<Review>> getReviewsByParent(String parentId) async {
    try {
      final result = await _db.query(
        '''
        SELECT r.*, u.name as parent_name
        FROM reviews r
        JOIN users u ON r.parent_id = u.id
        WHERE r.parent_id = @parentId
        ORDER BY r.created_at DESC
        ''',
        substitutionValues: {'parentId': parentId},
      );

      return result.map((row) {
        final review = row['reviews']!;
        final user = row['users']!;
        return Review(
          id: review['id'] as String,
          parentName: user['name'] as String,
          rating: (review['rating'] as num).toDouble(),
          comment: review['comment'] as String,
          date: review['created_at'].toString(),
        );
      }).toList();
    } catch (e) {
      print('Error getting parent reviews: $e');
      return [];
    }
  }

  // Update review
  Future<bool> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  }) async {
    try {
      await _db.execute(
        '''
        UPDATE reviews
        SET rating = COALESCE(@rating, rating),
            comment = COALESCE(@comment, comment),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = @reviewId
        ''',
        substitutionValues: {
          'reviewId': reviewId,
          'rating': rating,
          'comment': comment,
        },
      );
      return true;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

  // Delete review
  Future<bool> deleteReview(String reviewId) async {
    try {
      await _db.execute(
        'DELETE FROM reviews WHERE id = @reviewId',
        substitutionValues: {'reviewId': reviewId},
      );
      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }
}
