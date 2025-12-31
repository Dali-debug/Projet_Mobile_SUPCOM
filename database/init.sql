-- Nursery Management System Database Schema
-- Created: December 31, 2025

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (authentication and base user info)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('parent', 'nursery')),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Nurseries table
CREATE TABLE nurseries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    description TEXT,
    hours VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    photo_url TEXT,
    price_per_month DECIMAL(10, 2),
    available_spots INTEGER DEFAULT 0,
    total_spots INTEGER NOT NULL,
    staff_count INTEGER DEFAULT 0,
    age_range VARCHAR(50),
    rating DECIMAL(3, 2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Nursery facilities (many-to-many)
CREATE TABLE nursery_facilities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    facility_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nursery_id, facility_name)
);

-- Nursery activities (many-to-many)
CREATE TABLE nursery_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    activity_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nursery_id, activity_name)
);

-- Children table
CREATE TABLE children (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    age INTEGER NOT NULL,
    date_of_birth DATE,
    photo_url TEXT,
    medical_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enrollments (children enrolled in nurseries)
CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID REFERENCES children(id) ON DELETE CASCADE,
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('pending', 'active', 'completed', 'cancelled')),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(child_id, nursery_id)
);

-- Reviews table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
    rating DECIMAL(2, 1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enrollment_id UUID REFERENCES enrollments(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Conversations table
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    last_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(parent_id, nursery_id)
);

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    recipient_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_id UUID,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activities/Programs for children
CREATE TABLE child_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enrollment_id UUID REFERENCES enrollments(id) ON DELETE CASCADE,
    activity_name VARCHAR(255) NOT NULL,
    description TEXT,
    scheduled_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Homework/Assignments
CREATE TABLE homework (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enrollment_id UUID REFERENCES enrollments(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES for performance optimization
-- ============================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_nurseries_owner ON nurseries(owner_id);
CREATE INDEX idx_nurseries_city ON nurseries(city);
CREATE INDEX idx_nurseries_rating ON nurseries(rating);
CREATE INDEX idx_children_parent ON children(parent_id);
CREATE INDEX idx_enrollments_child ON enrollments(child_id);
CREATE INDEX idx_enrollments_nursery ON enrollments(nursery_id);
CREATE INDEX idx_enrollments_status ON enrollments(status);
CREATE INDEX idx_reviews_nursery ON reviews(nursery_id);
CREATE INDEX idx_reviews_parent ON reviews(parent_id);
CREATE INDEX idx_payments_enrollment ON payments(enrollment_id);
CREATE INDEX idx_payments_parent ON payments(parent_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_conversations_parent ON conversations(parent_id);
CREATE INDEX idx_conversations_nursery ON conversations(nursery_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_read ON messages(is_read);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger to update nursery rating after review insert/update/delete
CREATE OR REPLACE FUNCTION update_nursery_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE nurseries
    SET 
        rating = COALESCE((
            SELECT ROUND(AVG(rating)::numeric, 2)
            FROM reviews
            WHERE nursery_id = COALESCE(NEW.nursery_id, OLD.nursery_id)
        ), 0),
        review_count = (
            SELECT COUNT(*)
            FROM reviews
            WHERE nursery_id = COALESCE(NEW.nursery_id, OLD.nursery_id)
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = COALESCE(NEW.nursery_id, OLD.nursery_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_rating_insert
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_nursery_rating();

CREATE TRIGGER trigger_update_rating_update
AFTER UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_nursery_rating();

CREATE TRIGGER trigger_update_rating_delete
AFTER DELETE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_nursery_rating();

-- Trigger to update last_message_at in conversations
CREATE OR REPLACE FUNCTION update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET last_message_at = NEW.sent_at
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_conversation
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_timestamp();

-- Trigger to update updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_nurseries_updated_at BEFORE UPDATE ON nurseries
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_children_updated_at BEFORE UPDATE ON children
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_enrollments_updated_at BEFORE UPDATE ON enrollments
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SAMPLE DATA (for testing)
-- ============================================

-- Insert sample parent user
INSERT INTO users (email, password_hash, user_type, name, phone) VALUES
('parent1@example.com', '$2a$10$abcdefghijklmnopqrstuv', 'parent', 'Ahmed Ben Ali', '+216 20 123 456'),
('parent2@example.com', '$2a$10$abcdefghijklmnopqrstuv', 'parent', 'Fatima Trabelsi', '+216 20 456 789');

-- Insert sample nursery user
INSERT INTO users (email, password_hash, user_type, name, phone) VALUES
('nursery1@example.com', '$2a$10$abcdefghijklmnopqrstuv', 'nursery', 'Happy Kids Nursery', '+216 71 123 456'),
('nursery2@example.com', '$2a$10$abcdefghijklmnopqrstuv', 'nursery', 'Sunny Days Nursery', '+216 71 789 012');

-- Insert sample nurseries
INSERT INTO nurseries (owner_id, name, address, city, postal_code, latitude, longitude, description, hours, phone, email, photo_url, price_per_month, available_spots, total_spots, staff_count, age_range) VALUES
(
    (SELECT id FROM users WHERE email = 'nursery1@example.com'),
    'Happy Kids Nursery',
    '123 Avenue Habib Bourguiba',
    'Tunis',
    '1000',
    36.8065,
    10.1815,
    'A wonderful place for your children to learn and play',
    '7:00 AM - 6:00 PM',
    '+216 71 123 456',
    'contact@happykids.tn',
    'https://images.unsplash.com/photo-1587654780291-39c9404d746b',
    500.00,
    5,
    20,
    8,
    '6 months - 5 years'
),
(
    (SELECT id FROM users WHERE email = 'nursery2@example.com'),
    'Sunny Days Nursery',
    '456 Rue de la Liberté',
    'Sfax',
    '3000',
    34.7406,
    10.7603,
    'Quality care and education for your little ones',
    '6:30 AM - 7:00 PM',
    '+216 71 789 012',
    'info@sunnydays.tn',
    'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9',
    450.00,
    10,
    25,
    10,
    '1 year - 6 years'
);

-- Insert sample facilities
INSERT INTO nursery_facilities (nursery_id, facility_name) VALUES
((SELECT id FROM nurseries WHERE name = 'Happy Kids Nursery'), 'Playground'),
((SELECT id FROM nurseries WHERE name = 'Happy Kids Nursery'), 'Swimming Pool'),
((SELECT id FROM nurseries WHERE name = 'Happy Kids Nursery'), 'Music Room'),
((SELECT id FROM nurseries WHERE name = 'Sunny Days Nursery'), 'Garden'),
((SELECT id FROM nurseries WHERE name = 'Sunny Days Nursery'), 'Library'),
((SELECT id FROM nurseries WHERE name = 'Sunny Days Nursery'), 'Art Studio');

-- Insert sample activities
INSERT INTO nursery_activities (nursery_id, activity_name) VALUES
((SELECT id FROM nurseries WHERE name = 'Happy Kids Nursery'), 'Music Lessons'),
((SELECT id FROM nurseries WHERE name = 'Happy Kids Nursery'), 'Arts & Crafts'),
((SELECT id FROM nurseries WHERE name = 'Happy Kids Nursery'), 'Storytelling'),
((SELECT id FROM nurseries WHERE name = 'Sunny Days Nursery'), 'Dance Classes'),
((SELECT id FROM nurseries WHERE name = 'Sunny Days Nursery'), 'Outdoor Play'),
((SELECT id FROM nurseries WHERE name = 'Sunny Days Nursery'), 'Language Learning');

-- Database initialization complete
COMMENT ON DATABASE nursery_db IS 'Nursery Management System Database - Initialized on December 31, 2025';
