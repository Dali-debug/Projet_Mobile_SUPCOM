# Database Setup Guide

## Prerequisites
- Docker Desktop installed on your system
- Docker Compose

## Quick Start

### 1. Start the Database

```bash
docker-compose up -d
```

This will:
- Create and start a PostgreSQL 15 container
- Initialize the database with all tables and sample data
- Start pgAdmin (optional web interface)

### 2. Access the Database

**PostgreSQL Connection Details:**
- **Host:** localhost
- **Port:** 5432
- **Database:** nursery_db
- **Username:** nursery_admin
- **Password:** nursery_password_2025

**pgAdmin Web Interface:**
- URL: http://localhost:5050
- Email: admin@nursery.com
- Password: admin123

### 3. Stop the Database

```bash
docker-compose down
```

To remove all data:
```bash
docker-compose down -v
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

12. **child_activities** - Educational activities for enrolled children

13. **homework** - Homework/assignments for children

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
