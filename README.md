# JINEN - Application de Gestion de Garderie (Flutter)

A comprehensive Flutter application for finding, rating, and managing daycare/nursery services with integrated messaging system between parents and nursery owners.


## 🎯 Features

- **Parent Features**:
  - Search and browse nurseries
  - Rate and review nurseries
  - Manage child enrollments
  - Contact nurseries via messaging
  - View nursery details and ratings

- **Nursery Owner Features**:
  - Manage nursery profile
  - View enrolled children and parent information
  - Contact parents via messaging
  - Accept/manage enrollment requests
  - View performance metrics and ratings

- **Messaging System**:
  - Real-time conversations between parents and nursery owners
  - Create conversations automatically when needed
  - Message history and unread counts
  - Integrated chat interface

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- VS Code or Android Studio with Flutter plugin

## Getting Started

### 1. Install Flutter

Follow the official Flutter installation guide for your platform:
https://docs.flutter.dev/get-started/install

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Database Setup

You need to set up the PostgreSQL database before running the app.

#### Using Docker (Recommended)
Run the following command in the root directory:

```bash
docker-compose up -d
```
This will start PostgreSQL, pgAdmin, and the Backend server. The database will be automatically initialized with the required schema and sample data.

# Using psql command line tool (to generate data into the database)
psql -U postgres -d nursery_db -f database/init.sql
```

### 4. Run the backend
```
cd backend && npm start


### 5. Run the App
For Android:
```bash
flutter run -d android
```

For iOS (macOS only):

```bash
flutter run -d ios
```

For Web:

```bash
flutter run -d chrome
```

For Windows:

```bash
flutter run -d windows
```

### 4. Build Release Version

For Android:

```bash
flutter build apk --release
```

For iOS:

```bash
flutter build ios --release
```

For Web:

```bash
flutter build web --release
```

## Project Structure

```
lib/
  ├── main.dart                    # App entry point
  ├── app.dart                     # Main app widget
  ├── models/                      # Data models
  │   ├── user.dart
  │   ├── parent.dart
  │   ├── child.dart
  │   ├── enfant.dart
  │   ├── nursery.dart
  │   ├── garderie.dart
  │   ├── review.dart
  │   ├── avis.dart
  │   ├── conversation.dart
  │   ├── message.dart
  │   ├── notification.dart
  │   ├── paiement.dart
  │   ├── activite.dart
  │   ├── devoir.dart
  │   ├── programme.dart
  │   ├── directeur.dart
  │   └── utilisateur.dart
  ├── providers/                   # State management
  │   └── app_state.dart
  ├── screens/                     # UI screens
  │   ├── welcome_screen.dart
  │   ├── auth_screen.dart
  │   ├── parent_dashboard.dart
  │   ├── parent_children_screen.dart
  │   ├── parent_enrollments_screen.dart
  │   ├── parent_payment_screen.dart
  │   ├── parent_reviews_screen.dart
  │   ├── nursery_dashboard.dart
  │   ├── nursery_search.dart
  │   ├── nursery_details.dart
  │   ├── nursery_setup_screen.dart
  │   ├── nursery_settings_screen.dart
  │   ├── nursery_program_screen.dart
  │   ├── nursery_performance_screen.dart
  │   ├── nursery_statistics_screen.dart
  │   ├── nursery_financial_tracking_screen.dart
  │   ├── nursery_children_list_screen.dart
  │   ├── manage_enrolled_screen.dart
  │   ├── enrollment_screen.dart
  │   ├── chat_list_screen.dart
  │   ├── chat_screen.dart
  │   └── notifications_screen.dart
  ├── services/                    # API & Business Logic
  │   ├── user_service.dart
  │   ├── user_service_web.dart
  │   ├── child_service.dart
  │   ├── child_service_web.dart
  │   ├── nursery_service.dart
  │   ├── nursery_service_web.dart
  │   ├── enrollment_service.dart
  │   ├── enrollment_service_web.dart
  │   ├── enrolled_children_service_web.dart
  │   ├── parent_nurseries_service_web.dart
  │   ├── review_service.dart
  │   ├── review_service_web.dart
  │   ├── conversation_service.dart
  │   ├── conversation_service_web.dart
  │   ├── chat_service.dart
  │   ├── notification_service.dart
  │   ├── notification_service_web.dart
  │   ├── payment_service.dart
  │   ├── nursery_dashboard_service.dart
  │   ├── nursery_performance_service.dart
  │   ├── parent_program_service.dart
  │   ├── favorites_service.dart
  │   └── database_service.dart
  └── widgets/                     # Reusable UI components
      ├── app_drawer.dart
      ├── rate_nursery_dialog.dart
      └── theme_toggle.dart

backend/                           # Node.js/Express backend
  ├── server.js                    # Main server file
  ├── package.json
  ├── config/
  │   ├── database.js
  │   └── cors.js
  ├── routes/
  │   ├── auth.js
  │   ├── users.js
  │   ├── parents.js
  │   ├── nurseries.js
  │   ├── enrollments.js
  │   ├── reviews.js
  │   ├── conversations.js
  │   ├── notifications.js
  │   ├── payments.js
  │   └── schedule.js
  └── utils/
      └── helpers.js

database/                          # PostgreSQL database
  ├── init.sql                     # Database initialization
  ├── schema.sql                   # Database schema
  └── README.md
```

## Features

### Core Features
- **Welcome Screen**: Introduction to the app with navigation to authentication
- **Authentication**: Sign in and sign up functionality for parents and nursery owners
- **Multi-language Support**: French interface for better accessibility

### Parent Features
- **Dashboard**: Personalized overview of children and enrollments
- **Child Management**: Add, edit, and manage child profiles with details (name, age, birth date)
- **Nursery Search**: Browse and search for nurseries with advanced filtering options
- **Nursery Details**: View comprehensive information about nurseries including photos, ratings, and reviews
- **Enrollment Management**: 
  - Submit enrollment requests for children
  - Track enrollment status (Pending, Active, Completed, Cancelled)
  - View enrollment history
- **Rating & Review System**: 
  - Rate nurseries with a 5-star system
  - Write detailed reviews and comments
  - Update or delete existing reviews
  - View all reviews from other parents
- **Messaging**: Direct communication with nursery owners through integrated chat
- **Notifications**: Real-time updates on enrollments, messages, and important events
- **Payment Tracking**: View and manage payment history for enrolled children

### Nursery Owner Features
- **Nursery Dashboard**: Comprehensive management interface with key metrics
- **Nursery Profile Setup**: 
  - Complete nursery information (name, address, capacity, age range)
  - Upload photos and descriptions
  - Set opening hours and pricing
- **Enrollment Management**: 
  - View all enrollment requests
  - Accept or reject enrollment applications
  - Track enrolled children and their parents
- **Enrolled Children Dashboard**: 
  - View all parents and children enrolled in the nursery
  - Access parent contact information
  - Monitor enrollment status for each child
  - Real-time count of total parents and children
- **Program Management**: Create and manage daily activities and schedules
- **Performance Analytics**: 
  - View nursery ratings and reviews
  - Track enrollment statistics
  - Monitor financial performance
- **Financial Tracking**: Record and track payments from parents
- **Messaging**: Direct communication with parents through integrated chat
- **Notifications**: Stay updated on new enrollments, messages, and reviews

### Messaging System
- **Real-time Conversations**: Seamless messaging between parents and nursery owners
- **Conversation History**: Access to complete message history
- **Unread Count**: Visual indicators for unread messages
- **Automatic Conversation Creation**: System creates conversations when parents contact nurseries
- **Chat List**: Overview of all active conversations
- **Message Status**: Track sent and read status of messages

### Additional Features
- **Responsive Design**: Optimized for mobile (Android/iOS) and web platforms
- **Pull-to-Refresh**: Update data with simple pull gesture
- **Search & Filter**: Advanced search capabilities across nurseries
- **User-friendly Interface**: Intuitive navigation and modern design
- **Data Persistence**: Local and cloud data synchronization

## State Management

This app uses the `provider` package for state management. The main app state is managed in `AppState` class.

## Original Design

The original design is available at: https://www.figma.com/design/nyqz406RYiODaxJS88uq99/Smart-Farm-Irrigation-App (Note: This was the original design reference from another project)

## License

Private project

---

# 🔌 API INTEGRATION & MESSAGING SYSTEM

## Architecture Overview

The application uses a **3-tier architecture**:

```
┌─────────────────────────┐
│   Frontend (Flutter)    │  - User Interface
│   (Web/Android/iOS)     │  - Business Logic
└────────────┬────────────┘
             │ HTTP REST APIs
┌────────────▼────────────┐
│   Backend (Node.js)     │  - API Endpoints
│   Express Server        │  - Business Logic
│   Port: 3000            │
└────────────┬────────────┘
             │ Database Queries
┌────────────▼────────────┐
│  Database (PostgreSQL)  │  - Data Storage
│  Port: 5432             │  - Conversations
└─────────────────────────┘  - Messages
                              - Users & Nurseries
```

## 🚀 Running the Full System

### **1. Start Backend**
```bash
docker restart nursery_backend
```

Verify it's running:
```bash
docker ps | findstr nursery_backend
docker logs nursery_backend --tail 10
```

### **2. Start Frontend**
```bash
flutter run -d chrome
```

### **3. Test the Messaging System**

**As Parent**:
1. Log in with parent credentials
2. Go to "Mes Inscriptions"
3. Click "Contacter" on any enrollment
4. Type a message and send

**As Nursery Owner**:
1. Log in with nursery credentials
2. Go to "Gérer mes inscriptions"
3. Click "Contacter ce parent"
4. Type a message and send

---

## 📊 Database Relationships

```
users (Core user accounts)
  ├── id (UUID, PRIMARY KEY)
  ├── email (UNIQUE)
  ├── password_hash
  ├── user_type (parent/nursery)
  ├── name
  ├── phone
  ├── created_at
  └── updated_at

nurseries (Nursery information)
  ├── id (UUID, PRIMARY KEY)
  ├── owner_id (→ users.id) [FOREIGN KEY]
  ├── name
  ├── address
  ├── city
  ├── postal_code
  ├── latitude, longitude
  ├── description
  ├── hours
  ├── phone, email
  ├── photo_url
  ├── price_per_month
  ├── available_spots
  ├── total_spots
  ├── staff_count
  ├── age_range
  ├── rating (DECIMAL)
  ├── review_count
  ├── created_at
  └── updated_at

nursery_facilities (Nursery amenities)
  ├── id (UUID, PRIMARY KEY)
  ├── nursery_id (→ nurseries.id) [FOREIGN KEY]
  ├── facility_name
  ├── created_at
  └── UNIQUE(nursery_id, facility_name)

nursery_activities (Activities offered)
  ├── id (UUID, PRIMARY KEY)
  ├── nursery_id (→ nurseries.id) [FOREIGN KEY]
  ├── activity_name
  ├── created_at
  └── UNIQUE(nursery_id, activity_name)

children (Child profiles)
  ├── id (UUID, PRIMARY KEY)
  ├── parent_id (→ users.id) [FOREIGN KEY]
  ├── name
  ├── age
  ├── date_of_birth
  ├── photo_url
  ├── medical_notes
  ├── created_at
  └── updated_at

enrollments (Child-nursery registrations)
  ├── id (UUID, PRIMARY KEY)
  ├── child_id (→ children.id) [FOREIGN KEY]
  ├── nursery_id (→ nurseries.id) [FOREIGN KEY]
  ├── enrollment_date
  ├── status (pending/active/completed/cancelled)
  ├── start_date
  ├── end_date
  ├── created_at
  ├── updated_at
  └── UNIQUE(child_id, nursery_id)

reviews (Parent ratings & feedback)
  ├── id (UUID, PRIMARY KEY)
  ├── nursery_id (→ nurseries.id) [FOREIGN KEY]
  ├── parent_id (→ users.id) [FOREIGN KEY]
  ├── rating (0.0-5.0)
  ├── comment
  ├── created_at
  └── updated_at

payments (Financial transactions)
  ├── id (UUID, PRIMARY KEY)
  ├── enrollment_id (→ enrollments.id) [FOREIGN KEY]
  ├── parent_id (→ users.id) [FOREIGN KEY]
  ├── amount (DECIMAL)
  ├── payment_date
  ├── status (pending/completed/failed/refunded)
  ├── payment_method
  ├── transaction_id
  ├── description
  └── created_at

daily_schedule (Nursery programs)
  ├── id (UUID, PRIMARY KEY)
  ├── nursery_id (→ nurseries.id) [FOREIGN KEY]
  ├── title
  ├── description
  ├── scheduled_date
  ├── start_time, end_time
  ├── activity_type
  ├── created_at
  └── updated_at

conversations (Parent-nursery chat threads)
  ├── id (UUID, PRIMARY KEY)
  ├── parent_id (→ users.id) [FOREIGN KEY]
  ├── nursery_id (→ nurseries.id) [FOREIGN KEY]
  ├── last_message_at
  ├── created_at
  └── UNIQUE(parent_id, nursery_id)

messages (Individual chat messages)
  ├── id (UUID, PRIMARY KEY)
  ├── conversation_id (→ conversations.id) [FOREIGN KEY]
  ├── sender_id (→ users.id) [FOREIGN KEY]
  ├── recipient_id (→ users.id) [FOREIGN KEY]
  ├── content
  ├── is_read (BOOLEAN)
  └── sent_at

notifications (User notifications)
  ├── id (UUID, PRIMARY KEY)
  ├── user_id (→ users.id) [FOREIGN KEY]
  ├── type
  ├── title
  ├── message
  ├── is_read (BOOLEAN)
  ├── related_id (UUID)
  └── sent_at
```

### Relationships Summary
- **users** ← owns → **nurseries** (1:N)
- **users** (parents) ← has → **children** (1:N)
- **children** ← enrolled in → **nurseries** via **enrollments** (N:M)
- **nurseries** ← has → **reviews** from **users** (parents) (1:N)
- **enrollments** ← has → **payments** (1:N)
- **users** ← participates in → **conversations** with **nurseries** (N:M)
- **conversations** ← contains → **messages** (1:N)
- **nurseries** ← has → **daily_schedule**, **nursery_facilities**, **nursery_activities** (1:N)
- **users** ← receives → **notifications** (1:N)
