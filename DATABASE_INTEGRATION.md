# Database Services Documentation

Your Flutter app is now fully connected to the PostgreSQL database with complete CRUD operations for all tables.

## 📦 Created Services

### 1. **database_service.dart** - Core Database Connection
- Singleton pattern for connection management
- Query execution methods
- Transaction support

### 2. **user_service.dart** - User Management
- `createUser()` - Register new users (parent/nursery)
- `login()` - Authenticate users
- `getUserById()` - Get user details
- `updateUser()` - Update profile
- `deleteUser()` - Remove user

### 3. **nursery_service.dart** - Nursery Management
- `createNursery()` - Add new nursery with facilities & activities
- `getNurseryById()` - Get complete nursery details
- `searchNurseries()` - Search with filters (city, price, rating, spots)
- `getNurseriesByOwner()` - Get nurseries by owner
- `updateNursery()` - Update nursery info
- `deleteNursery()` - Remove nursery

### 4. **child_service.dart** - Children Management
- `createChild()` - Add new child
- `getChildById()` - Get child details
- `getChildrenByParent()` - Get all children of a parent
- `updateChild()` - Update child info
- `deleteChild()` - Remove child

### 5. **enrollment_service.dart** - Enrollment Management
- `createEnrollment()` - Enroll child in nursery
- `updateEnrollmentStatus()` - Change status (pending/active/completed/cancelled)
- `getEnrollmentsByChild()` - Get child's enrollments
- `getEnrollmentsByNursery()` - Get nursery's enrollments
- `deleteEnrollment()` - Remove enrollment

### 6. **review_service.dart** - Reviews Management
- `createReview()` - Add review for nursery
- `getReviewsByNursery()` - Get all nursery reviews
- `getReviewsByParent()` - Get parent's reviews
- `updateReview()` - Edit review
- `deleteReview()` - Remove review

### 7. **payment_service.dart** - Payment Management
- `createPayment()` - Create payment record
- `updatePaymentStatus()` - Update payment status
- `getPaymentsByParent()` - Get parent's payment history
- `getPaymentsByNursery()` - Get nursery's payments
- `getPaymentById()` - Get payment details

### 8. **conversation_service.dart** - Chat Management
- `getOrCreateConversation()` - Get/create conversation between parent & nursery
- `getConversationsByUser()` - Get all user conversations
- `sendMessage()` - Send message
- `getMessagesByConversation()` - Get all messages
- `markMessagesAsRead()` - Mark as read
- `getUnreadMessageCount()` - Count unread messages

### 9. **notification_service.dart** - Notifications
- `createNotification()` - Create notification
- `getNotificationsByUser()` - Get user notifications
- `markAsRead()` - Mark notification as read
- `markAllAsRead()` - Mark all as read
- `getUnreadCount()` - Count unread
- `deleteNotification()` - Delete notification

## 🚀 Usage Examples

### Example 1: User Registration & Login

```dart
import 'package:garderie/services/user_service.dart';
import 'package:garderie/models/user.dart';

final userService = UserService();

// Register new parent
Future<void> registerParent() async {
  final user = await userService.createUser(
    email: 'parent@example.com',
    password: 'secure_password',
    name: 'Ahmed Ben Ali',
    type: UserType.parent,
    phone: '+216 20 123 456',
  );
  
  if (user != null) {
    print('User registered: ${user.name}');
  }
}

// Login
Future<void> loginUser() async {
  final user = await userService.login(
    'parent@example.com',
    'secure_password',
  );
  
  if (user != null) {
    print('Login successful: ${user.name}');
    // Save user to state management
  }
}
```

### Example 2: Create Nursery

```dart
import 'package:garderie/services/nursery_service.dart';

final nurseryService = NurseryService();

Future<void> createNursery(String ownerId) async {
  final nursery = await nurseryService.createNursery(
    ownerId: ownerId,
    name: 'Happy Kids Nursery',
    address: '123 Avenue Habib Bourguiba',
    city: 'Tunis',
    postalCode: '1000',
    latitude: 36.8065,
    longitude: 10.1815,
    description: 'A wonderful place for children',
    hours: '7:00 AM - 6:00 PM',
    phone: '+216 71 123 456',
    email: 'contact@happykids.tn',
    pricePerMonth: 500.00,
    totalSpots: 20,
    staffCount: 8,
    ageRange: '6 months - 5 years',
    facilities: ['Playground', 'Swimming Pool', 'Music Room'],
    activities: ['Music Lessons', 'Arts & Crafts', 'Storytelling'],
  );
  
  if (nursery != null) {
    print('Nursery created: ${nursery.name}');
  }
}
```

### Example 3: Search Nurseries

```dart
Future<void> searchForNurseries() async {
  final nurseries = await nurseryService.searchNurseries(
    city: 'Tunis',
    maxPrice: 600.00,
    minAvailableSpots: 2,
    minRating: 4.0,
  );
  
  for (var nursery in nurseries) {
    print('${nursery.name} - ${nursery.rating}⭐ - ${nursery.price}DT/month');
  }
}
```

### Example 4: Enroll Child

```dart
import 'package:garderie/services/child_service.dart';
import 'package:garderie/services/enrollment_service.dart';

final childService = ChildService();
final enrollmentService = EnrollmentService();

Future<void> enrollChildInNursery(String parentId, String nurseryId) async {
  // Create child
  final child = await childService.createChild(
    parentId: parentId,
    name: 'Youssef',
    age: 3,
    dateOfBirth: DateTime(2022, 3, 15),
  );
  
  if (child != null) {
    // Enroll in nursery
    final enrollmentId = await enrollmentService.createEnrollment(
      childId: child.id,
      nurseryId: nurseryId,
      startDate: DateTime.now(),
    );
    
    if (enrollmentId != null) {
      // Activate enrollment
      await enrollmentService.updateEnrollmentStatus(
        enrollmentId: enrollmentId,
        status: 'active',
      );
      print('Child enrolled successfully!');
    }
  }
}
```

### Example 5: Send Message

```dart
import 'package:garderie/services/conversation_service.dart';

final conversationService = ConversationService();

Future<void> sendMessageToNursery(
  String parentId,
  String nurseryId,
  String messageContent,
) async {
  // Get or create conversation
  final conversationId = await conversationService.getOrCreateConversation(
    parentId: parentId,
    nurseryId: nurseryId,
  );
  
  if (conversationId != null) {
    // Send message
    final message = await conversationService.sendMessage(
      conversationId: conversationId,
      senderId: parentId,
      recipientId: nurseryId,
      content: messageContent,
    );
    
    if (message != null) {
      print('Message sent!');
    }
  }
}
```

### Example 6: Add Review

```dart
import 'package:garderie/services/review_service.dart';

final reviewService = ReviewService();

Future<void> addReview(String nurseryId, String parentId) async {
  final review = await reviewService.createReview(
    nurseryId: nurseryId,
    parentId: parentId,
    rating: 4.5,
    comment: 'Excellent nursery! My child loves it here.',
  );
  
  if (review != null) {
    print('Review added successfully!');
  }
}
```

### Example 7: Make Payment

```dart
import 'package:garderie/services/payment_service.dart';

final paymentService = PaymentService();

Future<void> makePayment(String enrollmentId, String parentId) async {
  final paymentId = await paymentService.createPayment(
    enrollmentId: enrollmentId,
    parentId: parentId,
    amount: 500.00,
    paymentMethod: 'Credit Card',
    transactionId: 'TXN123456789',
    description: 'Monthly payment - January 2025',
  );
  
  if (paymentId != null) {
    // Update status to completed
    await paymentService.updatePaymentStatus(
      paymentId: paymentId,
      status: 'completed',
    );
    print('Payment processed!');
  }
}
```

### Example 8: Get User's Data

```dart
Future<void> getUserDashboardData(String userId, UserType userType) async {
  if (userType == UserType.parent) {
    // Get parent's children
    final children = await childService.getChildrenByParent(userId);
    
    // Get payments
    final payments = await paymentService.getPaymentsByParent(userId);
    
    // Get conversations
    final conversations = await conversationService.getConversationsByUser(userId);
    
    // Get notifications
    final notifications = await NotificationService().getNotificationsByUser(userId);
    
    print('Children: ${children.length}');
    print('Payments: ${payments.length}');
    print('Conversations: ${conversations.length}');
    print('Notifications: ${notifications.length}');
  } else {
    // Get nursery owner's nurseries
    final nurseries = await nurseryService.getNurseriesByOwner(userId);
    
    for (var nursery in nurseries) {
      // Get enrollments
      final enrollments = await enrollmentService.getEnrollmentsByNursery(nursery.id);
      
      // Get reviews
      final reviews = await reviewService.getReviewsByNursery(nursery.id);
      
      print('${nursery.name}: ${enrollments.length} enrollments, ${reviews.length} reviews');
    }
  }
}
```

## 🔒 Connection Details

- **Host:** localhost
- **Port:** 5432
- **Database:** nursery_db
- **Username:** nursery_admin
- **Password:** nursery_password_2025

## ⚠️ Important Notes

1. **Close connections** when done:
   ```dart
   await DatabaseService.instance.close();
   ```

2. **Error handling** is included in all services

3. **Passwords are hashed** using SHA-256 in UserService

4. **Automatic triggers** update:
   - Nursery ratings when reviews are added/updated/deleted
   - Conversation timestamps when messages are sent
   - Available spots when enrollment status changes

## 🎯 Next Steps

1. Integrate these services into your screens
2. Add proper state management (Provider is already in pubspec.yaml)
3. Handle loading states and errors in UI
4. Add offline support if needed
5. Implement proper authentication flow

All database operations are ready to use! 🚀
