const http = require('http');

// Test data
const enrollmentData = {
  childName: "Ahmed Ben Ali",
  birthDate: "2020-05-15",
  parentName: "Mohamed Ben Ali",
  parentPhone: "+216 98 765 432",
  nurseryId: "1",
  startDate: "2026-02-01",
  notes: "L'enfant a des allergies aux arachides"
};

// Prepare the request
const postData = JSON.stringify(enrollmentData);

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/enrollments',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('🧪 Testing enrollment API...\n');
console.log('📤 Sending enrollment data:');
console.log(JSON.stringify(enrollmentData, null, 2));
console.log('\n⏳ Waiting for response...\n');

const req = http.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log(`📊 Status Code: ${res.statusCode}`);
    console.log('📥 Response:');
    try {
      const response = JSON.parse(data);
      console.log(JSON.stringify(response, null, 2));
      
      if (response.success) {
        console.log('\n✅ Inscription créée avec succès!');
        console.log(`   ID Inscription: ${response.enrollment.id}`);
        console.log(`   ID Enfant: ${response.enrollment.childId}`);
        console.log(`   ID Parent: ${response.enrollment.parentId}`);
      } else {
        console.log('\n❌ Erreur lors de la création de l\'inscription');
      }
    } catch (e) {
      console.log(data);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Error:', error.message);
  console.log('\n💡 Assurez-vous que le serveur backend est en cours d\'exécution sur le port 3000');
});

req.write(postData);
req.end();
