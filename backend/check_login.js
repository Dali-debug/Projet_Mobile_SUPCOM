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

async function checkLogin() {
  try {
    const email = 'test@parent.com';
    const password = 'test123';
    const expectedHash = hashPassword(password);
    
    console.log('🔍 Vérification de connexion:');
    console.log('Email:', email);
    console.log('Password:', password);
    console.log('Hash attendu:', expectedHash);
    
    const result = await pool.query(
      'SELECT email, password_hash, user_type FROM users WHERE email = $1',
      [email]
    );
    
    if (result.rows.length > 0) {
      const user = result.rows[0];
      console.log('\n✅ Utilisateur trouvé:');
      console.log('Email:', user.email);
      console.log('Type:', user.user_type);
      console.log('Hash DB:', user.password_hash);
      console.log('\nComparaison:', user.password_hash === expectedHash ? '✅ MATCH' : '❌ NO MATCH');
    } else {
      console.log('\n❌ Utilisateur non trouvé');
    }
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  } finally {
    await pool.end();
  }
}

checkLogin();
