const axios = require('axios');

async function testLogin() {
  try {
    console.log('🔐 Test de connexion...\n');
    
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'test@parent.com',
      password: 'test123'
    });
    
    console.log('✅ Connexion réussie!');
    console.log('Réponse:', JSON.stringify(response.data, null, 2));
    
  } catch (error) {
    console.error('❌ Erreur de connexion:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Données:', error.response.data);
    } else {
      console.error('Message:', error.message);
    }
  }
}

testLogin();
