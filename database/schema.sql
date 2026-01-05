-- Nursery Management System Database Schema
-- Created: January 5, 2026
-- Updated: Removed homework and child_activities tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- CORE TABLES
-- ============================================

-- Users table (authentication and base user info)
CREATE TABLE IF NOT EXISTS users (
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
CREATE TABLE IF NOT EXISTS nurseries (
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
CREATE TABLE IF NOT EXISTS nursery_facilities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    facility_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nursery_id, facility_name)
);

-- Nursery activities (many-to-many)
CREATE TABLE IF NOT EXISTS nursery_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    activity_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nursery_id, activity_name)
);

-- Children table
CREATE TABLE IF NOT EXISTS children (
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
CREATE TABLE IF NOT EXISTS enrollments (
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
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
    rating DECIMAL(2, 1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
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

-- Daily schedule table for nursery programs
CREATE TABLE IF NOT EXISTS daily_schedule (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    scheduled_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    activity_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- MESSAGING & COMMUNICATION TABLES
-- ============================================

-- Conversations table
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
    nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
    last_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(parent_id, nursery_id)
);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    recipient_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_id UUID,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES for performance optimization
-- ============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_nurseries_owner ON nurseries(owner_id);
CREATE INDEX IF NOT EXISTS idx_nurseries_city ON nurseries(city);
CREATE INDEX IF NOT EXISTS idx_nurseries_rating ON nurseries(rating);
CREATE INDEX IF NOT EXISTS idx_children_parent ON children(parent_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_child ON enrollments(child_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_nursery ON enrollments(nursery_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_status ON enrollments(status);
CREATE INDEX IF NOT EXISTS idx_reviews_nursery ON reviews(nursery_id);
CREATE INDEX IF NOT EXISTS idx_reviews_parent ON reviews(parent_id);
CREATE INDEX IF NOT EXISTS idx_payments_enrollment ON payments(enrollment_id);
CREATE INDEX IF NOT EXISTS idx_payments_parent ON payments(parent_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_conversations_parent ON conversations(parent_id);
CREATE INDEX IF NOT EXISTS idx_conversations_nursery ON conversations(nursery_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_read ON messages(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_daily_schedule_nursery ON daily_schedule(nursery_id);
CREATE INDEX IF NOT EXISTS idx_daily_schedule_date ON daily_schedule(scheduled_date);

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

DROP TRIGGER IF EXISTS trigger_update_rating_insert ON reviews;
CREATE TRIGGER trigger_update_rating_insert
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_nursery_rating();

DROP TRIGGER IF EXISTS trigger_update_rating_update ON reviews;
CREATE TRIGGER trigger_update_rating_update
AFTER UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_nursery_rating();

DROP TRIGGER IF EXISTS trigger_update_rating_delete ON reviews;
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

DROP TRIGGER IF EXISTS trigger_update_conversation ON messages;
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

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_nurseries_updated_at ON nurseries;
CREATE TRIGGER update_nurseries_updated_at BEFORE UPDATE ON nurseries
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_children_updated_at ON children;
CREATE TRIGGER update_children_updated_at BEFORE UPDATE ON children
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_enrollments_updated_at ON enrollments;
CREATE TRIGGER update_enrollments_updated_at BEFORE UPDATE ON enrollments
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_daily_schedule_updated_at ON daily_schedule;
CREATE TRIGGER update_daily_schedule_updated_at BEFORE UPDATE ON daily_schedule
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE users IS 'User accounts for parents and nursery owners';
COMMENT ON TABLE nurseries IS 'Nursery/daycare information';
COMMENT ON TABLE children IS 'Children registered by parents';
COMMENT ON TABLE enrollments IS 'Children enrolled in nurseries';
COMMENT ON TABLE reviews IS 'Parent reviews and ratings for nurseries';
COMMENT ON TABLE payments IS 'Payment transactions for enrollments';
COMMENT ON TABLE daily_schedule IS 'Daily activities and programs scheduled by nurseries';
COMMENT ON TABLE conversations IS 'Chat conversations between parents and nurseries';
COMMENT ON TABLE messages IS 'Individual messages within conversations';
COMMENT ON TABLE notifications IS 'System notifications for users';
