# Database Setup Guide

This folder contains the database schema and initialization files for the Nursery Management System.

## Files in this folder

- **schema.sql** - Complete database schema (tables, indexes, triggers). Use this to create a fresh database.
- **init.sql** - Database schema with sample data for testing and development.
- **README.md** - This documentation file.

## Prerequisites
- PostgreSQL 15 or higher
- Docker Desktop (optional, if using docker-compose)

## Setup Options

### Option 1: Using Docker (Recommended)

1. Start the database with Docker Compose:
```bash
docker-compose up -d
```

This will:
- Create and start a PostgreSQL 15 container
- Initialize the database with all tables and sample data from init.sql
- Start pgAdmin (optional web interface)

2. The database will be automatically initialized with:
   - All required tables
   - Indexes and triggers
   - Sample data for testing

### Option 2: Manual Setup

If you prefer to set up PostgreSQL manually:

1. Create a new database:
```sql
CREATE DATABASE nursery_db;
```

2. Run the schema file:
```bash
psql -U your_username -d nursery_db -f schema.sql
```

Or if you want sample data:
```bash
psql -U your_username -d nursery_db -f init.sql
```

## Database Connection Details

**PostgreSQL Connection:**
- **Host:** localhost
- **Port:** 5432
- **Database:** nursery_db
- **Username:** nursery_admin
- **Password:** nursery_password_2025

**pgAdmin Web Interface (if using Docker):**
- URL: http://localhost:5050
- Email: admin@nursery.com
- Password: admin123

## Managing the Docker Database

### Stop the Database
```bash
docker-compose down
```

### Stop and Remove All Data
```bash
docker-compose down -v
```

### Restart the Database
```bash
docker-compose restart
```

## Database Structure

### Core Tables

1. **users** - Authentication and user base information
   - Stores both parents and nursery owners
   - Fields: id, email, password_hash, user_type, name, phone

2. **nurseries** - Nursery information
   - Complete nursery details including location, pricing, capacity
   - Fields: id, owner_id, name, address, city, description, rating, etc.

3. **children** - Children profiles
   - Linked to parent users
   - Fields: id, parent_id, name, age, date_of_birth, photo_url

4. **enrollments** - Children enrolled in nurseries
   - Links children to nurseries with status tracking
   - Fields: id, child_id, nursery_id, status, start_date, end_date

5. **reviews** - Parent reviews for nurseries
   - Automatic rating calculation via triggers
   - Fields: id, nursery_id, parent_id, rating, comment

6. **payments** - Payment tracking
   - Transaction history and status
   - Fields: id, enrollment_id, parent_id, amount, status, transaction_id

7. **conversations** - Chat conversations
   - Between parents and nursery owners
   - Fields: id, parent_id, nursery_id, last_message_at

8. **messages** - Individual messages
   - Linked to conversations
   - Fields: id, conversation_id, sender_id, recipient_id, content, is_read

9. **notifications** - System notifications
   - User notifications with read status
   - Fields: id, user_id, type, message, is_read

10. **nursery_facilities** - Nursery facilities (many-to-many)

11. **nursery_activities** - Nursery activities (many-to-many)

12. **daily_schedule** - Daily activities and programs scheduled by nurseries

## Useful Commands

### Connect to PostgreSQL CLI
```bash
docker exec -it nursery_db psql -U nursery_admin -d nursery_db
```

### View logs
```bash
docker-compose logs -f postgres
```

### Backup database
```bash
docker exec nursery_db pg_dump -U nursery_admin nursery_db > backup.sql
```

### Restore database
```bash
docker exec -i nursery_db psql -U nursery_admin nursery_db < backup.sql
```

### Reset database
```bash
docker-compose down -v
docker-compose up -d
```

## Connecting from Flutter

Add to your `pubspec.yaml`:
```yaml
dependencies:
  postgres: ^2.6.0
```

Example connection:
```dart
import 'package:postgres/postgres.dart';

final connection = PostgreSQLConnection(
  'localhost',
  5432,
  'nursery_db',
  username: 'nursery_admin',
  password: 'nursery_password_2025',
);

await connection.open();
```

## Security Notes

⚠️ **Important:** 
- Change default passwords in production
- Use environment variables for sensitive data
- Enable SSL/TLS for production databases
- Implement proper access controls

## Troubleshooting

### Port already in use
If port 5432 is already in use, modify `docker-compose.yml`:
```yaml
ports:
  - "5433:5432"  # Use different host port
```

### Container won't start
Check logs:
```bash
docker-compose logs postgres
```

### Reset everything
```bash
docker-compose down -v
docker system prune -a
docker-compose up -d
```
