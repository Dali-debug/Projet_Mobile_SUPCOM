# 🏫 JINEN - Application de Gestion de Garderie

Application mobile/web complète pour la gestion des garderies en Tunisie, développée avec Flutter et Node.js.

## 📋 Table des Matières

- [Description](#description)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Lancement de l'Application](#lancement-de-lapplication)
- [Comptes de Test](#comptes-de-test)
- [Fonctionnalités](#fonctionnalités)
- [Architecture](#architecture)
- [Technologies Utilisées](#technologies-utilisées)
- [Dépannage](#dépannage)

---

## 📖 Description

**JINEN** est une plateforme complète qui connecte les parents avec des garderies de qualité. L'application permet aux parents de rechercher, comparer et inscrire leurs enfants dans des garderies, tout en offrant aux gestionnaires de garderies des outils puissants pour gérer leurs établissements.

### Utilisateurs Cibles

- **Parents** : Rechercher et inscrire leurs enfants dans des garderies
- **Gestionnaires de Garderies** : Gérer leur établissement, les inscriptions, les paiements et communiquer avec les parents

---

## 🔧 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

### Obligatoire

- **Flutter SDK** (>=3.0.0) - [Installation](https://flutter.dev/docs/get-started/install)
- **Node.js** (v18 ou supérieur) - [Télécharger](https://nodejs.org/)
- **Docker Desktop** - [Télécharger](https://www.docker.com/products/docker-desktop)
- **Git** - [Télécharger](https://git-scm.com/)

### Optionnel

- **VS Code** avec les extensions Flutter et Dart
- **Chrome** (pour tester la version web)
- **Android Studio** / **Xcode** (pour les builds mobiles)

---

## 📦 Installation

### 1. Cloner le Projet

```bash
git clone https://github.com/Dali-debug/Projet_Mobile_SUPCOM.git
cd Projet_Mobile_SUPCOM
```

### 2. Installer les Dépendances Flutter

```bash
flutter pub get
```

### 3. Installer les Dépendances Backend

```bash
cd backend
npm install
cd ..
```

### 4. Vérifier l'Installation

```bash
flutter doctor
```

Assurez-vous qu'il n'y a pas d'erreurs critiques (les ✓ verts).

---

## ⚙️ Configuration

### 1. Lancer Docker Desktop

- Ouvrez **Docker Desktop**
- Attendez que Docker soit complètement démarré (icône verte)

### 2. Configuration de la Base de Données

Le fichier `.env` à la racine contient déjà la configuration :

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nursery_db
DB_USER=nursery_admin
DB_PASSWORD=nursery_password_2025
```

Le fichier `backend/.env` doit contenir :

```env
PORT=3000
DB_HOST=postgres
DB_PORT=5432
DB_NAME=nursery_db
DB_USER=nursery_admin
DB_PASSWORD=nursery_password_2025
```

⚠️ **Important** : `DB_HOST=postgres` pour le backend (utilisé dans Docker)

### 3. Lancer les Services Docker

```bash
docker-compose up -d
```

Cette commande va :
- ✅ Créer et démarrer PostgreSQL (port 5432)
- ✅ Initialiser la base de données avec le schéma
- ✅ Démarrer le backend Node.js (port 3000)
- ✅ Démarrer pgAdmin (port 5050)

### 4. Vérifier les Conteneurs

```bash
docker ps
```

Vous devriez voir 3 conteneurs en cours d'exécution :
- `nursery_db` (PostgreSQL)
- `nursery_backend` (API Node.js)
- `nursery_pgadmin` (Interface de gestion DB)

### 5. Créer les Comptes de Test

```bash
cd backend
node add_test_accounts.js
cd ..
```

---

## 🚀 Lancement de l'Application

### Version Web (Chrome)

```bash
flutter run -d chrome
```

### Version Windows

```bash
flutter run -d windows
```

### Version Android (avec émulateur ou device)

```bash
flutter run -d android
```

### Mode Debug avec Hot Reload

Une fois l'application lancée :
- Appuyez sur `r` pour hot reload
- Appuyez sur `R` pour hot restart
- Appuyez sur `q` pour quitter

---

## 👤 Comptes de Test

### Compte Parent

```
Email:    test@parent.com
Password: test123
Type:     Parent (recherche de garderie)
```

**Fonctionnalités accessibles :**
- Rechercher des garderies
- Ajouter des enfants
- Inscrire des enfants dans des garderies
- Effectuer des paiements
- Discuter avec les garderies
- Laisser des avis

### Compte Garderie

```
Email:    test@nursery.com
Password: test123
Type:     Gestionnaire de Garderie
```

**Fonctionnalités accessibles :**
- Gérer les informations de la garderie
- Voir les inscriptions
- Gérer les paiements
- Communiquer avec les parents
- Voir les statistiques et performances

---

## ✨ Fonctionnalités

### 👨‍👩‍👧 Pour les Parents

#### 🔍 Recherche et Découverte
- Recherche de garderies par ville, prix, note
- Filtres avancés (équipements, activités, âge)
- Cartes interactives avec localisation
- Galeries de photos

#### 👶 Gestion des Enfants
- Ajout de profils d'enfants
- Informations médicales
- Suivi des inscriptions

#### 💳 Inscriptions et Paiements
- Inscription en ligne
- Paiement sécurisé
- Historique des paiements
- Notifications de paiement

#### 💬 Communication
- Chat en temps réel avec les garderies
- Notifications instantanées
- Historique des conversations

#### ⭐ Avis et Évaluations
- Laisser des avis
- Noter les garderies (1-5 étoiles)
- Voir les avis d'autres parents

### 🏫 Pour les Gestionnaires

#### 📊 Tableau de Bord
- Vue d'ensemble des statistiques
- Nombre d'enfants inscrits
- Revenus mensuels/annuels
- Taux d'occupation

#### 👥 Gestion des Inscriptions
- Liste des enfants inscrits
- Informations détaillées
- Statut des paiements
- Acceptation/refus d'inscriptions

#### 💰 Suivi Financier
- Historique des paiements
- Revenus par période
- Paiements en attente
- Rapports financiers

#### 📈 Performance
- Évolution des inscriptions
- Analyse des revenus
- Taux de satisfaction
- Statistiques détaillées

#### ⚙️ Configuration
- Modifier les informations de la garderie
- Gérer les équipements et activités
- Définir les tarifs
- Mettre à jour les photos

---

## 🏗️ Architecture

### Structure du Projet

```
Projet_Mobile_SUPCOM/
├── lib/                      # Code source Flutter
│   ├── models/              # Modèles de données
│   ├── providers/           # Gestion d'état (Provider)
│   ├── screens/             # Écrans de l'application
│   ├── services/            # Services API et logique métier
│   ├── widgets/             # Composants réutilisables
│   ├── utils/               # Utilitaires et helpers
│   ├── app.dart             # Configuration de l'app
│   └── main.dart            # Point d'entrée
│
├── backend/                  # Backend Node.js
│   ├── server.js            # API Express
│   ├── package.json         # Dépendances Node
│   └── .env                 # Configuration backend
│
├── database/                 # Scripts SQL
│   ├── init.sql             # Schéma de la base de données
│   └── *.sql                # Migrations et scripts
│
├── docker-compose.yml        # Configuration Docker
├── pubspec.yaml             # Dépendances Flutter
└── README.md                # Documentation principale
```

### Stack Technique

#### Frontend (Flutter)
- **UI Framework** : Flutter 3.0+
- **State Management** : Provider
- **HTTP Client** : http package
- **Database Client** : postgres package
- **Image Handling** : cached_network_image, image_picker
- **Cryptographie** : crypto (SHA-256)

#### Backend (Node.js)
- **Runtime** : Node.js 18
- **Framework** : Express.js
- **Database** : PostgreSQL 15
- **ORM/Query** : node-postgres (pg)
- **CORS** : cors middleware

#### Infrastructure
- **Containerization** : Docker & Docker Compose
- **Database** : PostgreSQL 15 Alpine
- **DB Management** : pgAdmin 4

---

## 🔌 API Endpoints

### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion

### Garderies
- `GET /api/nurseries` - Liste des garderies
- `GET /api/nurseries/:id` - Détails d'une garderie
- `POST /api/nurseries` - Créer une garderie
- `PUT /api/nurseries/:id` - Modifier une garderie

### Enfants
- `GET /api/children` - Liste des enfants
- `POST /api/children` - Ajouter un enfant
- `PUT /api/children/:id` - Modifier un enfant

### Inscriptions
- `POST /api/enrollments` - Créer une inscription
- `GET /api/enrollments` - Liste des inscriptions

### Paiements
- `POST /api/payments` - Effectuer un paiement
- `GET /api/payments` - Historique des paiements

### Messages
- `GET /api/conversations` - Liste des conversations
- `POST /api/messages` - Envoyer un message
- `GET /api/messages/:conversationId` - Messages d'une conversation

### Avis
- `POST /api/reviews` - Laisser un avis
- `GET /api/reviews/:nurseryId` - Avis d'une garderie

---

## 🐳 Services Docker

### PostgreSQL (nursery_db)
- **Port** : 5432
- **Accès** : localhost:5432
- **Utilisateur** : nursery_admin
- **Mot de passe** : nursery_password_2025
- **Base** : nursery_db

### Backend API (nursery_backend)
- **Port** : 3000
- **URL** : http://localhost:3000
- **API** : http://localhost:3000/api

### pgAdmin (nursery_pgadmin)
- **Port** : 5050
- **URL** : http://localhost:5050
- **Email** : admin@nursery.com
- **Mot de passe** : admin123

**Pour se connecter à la DB depuis pgAdmin :**
1. Ouvrez http://localhost:5050
2. Connectez-vous avec les identifiants ci-dessus
3. Créez une nouvelle connexion serveur :
   - Nom : Nursery DB
   - Host : postgres (ou nursery_db)
   - Port : 5432
   - Database : nursery_db
   - Username : nursery_admin
   - Password : nursery_password_2025

---

## 🔧 Dépannage

### Le backend ne se connecte pas à la base de données

**Problème** : `ECONNREFUSED ::1:5432`

**Solution** :
1. Vérifiez que `backend/.env` contient `DB_HOST=postgres` (pas `localhost`)
2. Redémarrez les conteneurs :
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Port 3000 déjà utilisé

**Problème** : `EADDRINUSE: address already in use :::3000`

**Solution** :
- Le backend Docker est déjà en cours d'exécution
- Pas besoin de lancer `npm start` localement
- OU arrêtez Docker et utilisez le backend local :
  ```bash
  docker-compose down
  cd backend
  npm start
  ```

### Flutter ne compile pas

**Solution** :
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Docker Desktop ne démarre pas

**Solution** :
1. Redémarrez votre ordinateur
2. Ouvrez Docker Desktop en tant qu'administrateur
3. Vérifiez que la virtualisation est activée dans le BIOS

### Les conteneurs ne démarrent pas

**Solution** :
```bash
docker-compose down -v
docker-compose up -d
```

L'option `-v` supprime les volumes et force une réinitialisation complète.

### Connexion échoue avec "Email ou mot de passe incorrect"

**Solution** :
1. Recréez les comptes de test :
   ```bash
   cd backend
   node add_test_accounts.js
   ```
2. Vérifiez que le backend est connecté à la DB :
   ```bash
   docker logs nursery_backend
   ```

---

## 📱 Builds Production

### Android APK

```bash
flutter build apk --release
```

Le fichier APK sera dans : `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (AAB)

```bash
flutter build appbundle --release
```

### Windows

```bash
flutter build windows --release
```

### Web

```bash
flutter build web --release
```

Les fichiers seront dans : `build/web/`

---

## 📝 Scripts Utiles

### Backend

```bash
# Créer des comptes de test
node backend/add_test_accounts.js

# Tester la connexion
node backend/test_login.js

# Vérifier la base de données
node backend/check_database.js
```

### Docker

```bash
# Voir les logs
docker logs nursery_backend
docker logs nursery_db

# Redémarrer un service
docker restart nursery_backend

# Arrêter tous les services
docker-compose down

# Démarrer tous les services
docker-compose up -d

# Voir les conteneurs actifs
docker ps
```

### Flutter

```bash
# Nettoyer le projet
flutter clean

# Récupérer les dépendances
flutter pub get

# Analyser le code
flutter analyze

# Lancer les tests
flutter test
```

---

## 📄 Licence

Ce projet est développé dans le cadre d'un projet académique à SUPCOM.

---

## 👥 Contributeurs

- **Équipe de développement SUPCOM**
- Projet Mobile - Gestion de Garderie

---

## 📞 Support

Pour toute question ou problème :
1. Consultez la section [Dépannage](#dépannage)
2. Vérifiez les logs Docker : `docker logs nursery_backend`
3. Vérifiez que tous les services sont actifs : `docker ps`

---

## 🎯 Roadmap

### Fonctionnalités à venir
- [ ] Notifications push
- [ ] Paiement en ligne (intégration gateway)
- [ ] Système de réservation temporaire
- [ ] Chat vidéo
- [ ] Application mobile native (iOS/Android)
- [ ] Tableau de bord analytique avancé
- [ ] Export de rapports (PDF/Excel)

---

**Bon développement ! 🚀**
