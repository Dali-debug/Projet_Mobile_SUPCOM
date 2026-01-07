const { Pool } = require('pg');
const crypto = require('crypto');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function addTestAccounts() {
  try {
    console.log('🔄 Adding test accounts...');
    
    // Hash for password "test123"
    const testPasswordHash = hashPassword('test123');
    
    // Insert test parent account
    await pool.query(`
      INSERT INTO users (email, password_hash, user_type, name, phone) 
      VALUES ($1, $2, 'parent', 'Test Parent', '+216 20 111 222')
      ON CONFLICT (email) DO UPDATE SET password_hash = $2
    `, ['test@parent.com', testPasswordHash]);
    
    console.log('✅ Parent test account created:');
    console.log('   Email: test@parent.com');
    console.log('   Password: test123');
    
    // Insert test nursery owner account
    const nurseryResult = await pool.query(`
      INSERT INTO users (email, password_hash, user_type, name, phone) 
      VALUES ($1, $2, 'nursery', 'Test Nursery Owner', '+216 71 333 444')
      ON CONFLICT (email) DO UPDATE SET password_hash = $2
      RETURNING id
    `, ['test@nursery.com', testPasswordHash]);
    
    const nurseryOwnerId = nurseryResult.rows[0].id;
    
    // Check if nursery already exists
    const existingNursery = await pool.query(
      'SELECT id FROM nurseries WHERE owner_id = $1',
      [nurseryOwnerId]
    );
    
    if (existingNursery.rows.length === 0) {
      // Insert test nursery
      await pool.query(`
        INSERT INTO nurseries (owner_id, name, address, city, postal_code, latitude, longitude, 
                              description, hours, phone, email, price_per_month, available_spots, 
                              total_spots, staff_count, age_range)
        VALUES ($1, 'Test Nursery', '789 Test Street', 'Tunis', '1000', 36.8065, 10.1815,
                'A test nursery for development', '8:00 AM - 5:00 PM', '+216 71 333 444',
                'test@nursery.com', 400.00, 15, 15, 5, '1 year - 5 years')
      `, [nurseryOwnerId]);
    }
    
    console.log('✅ Nursery test account created:');
    console.log('   Email: test@nursery.com');
    console.log('   Password: test123');
    
    console.log('\n🎉 Test accounts ready to use!');
    
  } catch (error) {
    console.error('❌ Error adding test accounts:', error);
  } finally {
    await pool.end();
  }
}

addTestAccounts();
