PlaniTâche

Application moderne de gestion intelligente des tâches quotidiennes développée avec Flutter, Spring Boot et MongoDB.

Description

PlaniTâche est une application mobile/web permettant aux utilisateurs d’organiser efficacement leurs journées, suivre leurs tâches quotidiennes et analyser leur productivité grâce à des statistiques intelligentes.

Le projet a été conçu avec une architecture moderne séparant :

le frontend Flutter
le backend Spring Boot REST API
la base de données MongoDB

L’application permet :

la création et gestion des tâches
le suivi de progression
les statistiques de productivité
l’authentification sécurisée avec JWT
la planification par calendrier
l’ajout de commentaires et notes
la saisie vocale intelligente
Technologies utilisées
Frontend
Flutter
Provider (State Management)
Material Design
Backend
Spring Boot 3
Spring Security
JWT Authentication
Spring Data MongoDB
Maven
Base de données
MongoDB
Outils
Git / GitHub
VS Code
Postman
Architecture du projet
PlaniTache
│
├── backend_springboot
│   ├── controller
│   ├── service
│   ├── repository
│   ├── entity
│   ├── dto
│   └── config
│
├── frontend_flutter
│   ├── lib
│   │   ├── models
│   │   ├── providers
│   │   ├── screens
│   │   └── core
│
└── MongoDB
Fonctionnalités principales
Authentification
Inscription utilisateur
Connexion sécurisée JWT
Gestion du profil
Déconnexion
Gestion des tâches
Ajouter une tâche
Modifier une tâche
Supprimer une tâche
Marquer comme terminée
Ajouter des commentaires
Ajouter un niveau de satisfaction
Gestion des priorités
Gestion des catégories
Calendrier
Affichage des tâches par date
Historique des tâches
Consultation des tâches futures
Visualisation des tâches terminées/non terminées
Statistiques
Pourcentage de productivité
Taux de tâches terminées
Statistiques hebdomadaires
Analyse des catégories
Satisfaction moyenne
Fonctionnalité intelligente
Saisie vocale intelligente
Analyse NLP simple des commandes vocales

Exemple :

"Demain à 14h réunion Spring Boot"
Sécurité

Le backend utilise :

Spring Security
JWT Authentication
Validation des requêtes
Protection des routes API
API REST
Auth
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/profile
Tasks
GET    /api/tasks
POST   /api/tasks
PUT    /api/tasks/{id}
DELETE /api/tasks/{id}
Notes
POST   /api/tasks/{id}/notes
DELETE /api/tasks/{id}/notes/{noteId}
Statistics
GET /api/statistics
Installation du projet
1. Cloner le projet
git clone https://github.com/FatimetouMahand/PlaniTache.git
Backend
2. Aller dans le backend
cd backend_springboot
3. Démarrer MongoDB

MongoDB doit fonctionner sur :

mongodb://localhost:27017/planitache
4. Lancer le backend
mvn spring-boot:run

Backend disponible sur :

http://localhost:8080
Frontend Flutter
5. Aller dans le frontend
cd frontend_flutter
6. Installer les dépendances
flutter pub get
7. Lancer l’application
flutter run -d chrome
Captures d’écran
Authentification moderne
Dashboard quotidien
Gestion intelligente des tâches
Calendrier interactif
Statistiques de productivité
Profil utilisateur
Auteur

Projet développé par :

FatimetouMahand
Objectif académique

Ce projet a été réalisé dans le cadre d’un projet universitaire orienté :

développement backend Spring Boot
architecture REST API
sécurité JWT
intégration Flutter + Backend
gestion MongoDB
Évolutions futures
Notifications push
IA NLP avancée
Synchronisation cloud
Mode sombre
Collaboration multi-utilisateurs
Export PDF des statistiques
Version mobile Android/iOS complète
