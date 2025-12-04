# Projet CI/CD - Wassim Frigui

## Description
Projet de pipeline DevOps complète avec :
- Détection automatique des commits Git
- Build automatique Jenkins
- Construction d'image Docker
- Publication sur Docker Hub

## Structure
wassim-frigui/
├── app.py # Application Flask
├── requirements.txt # Dépendances Python
├── Dockerfile # Construction Docker
├── Jenkinsfile # Pipeline CI/CD
└── README.md # Documentation


## Pipeline Jenkins
1. **Checkout** : Récupération du code
2. **Build** : Nettoyage et préparation
3. **Docker Build** : Construction de l'image
4. **Docker Push** : Publication sur Docker Hub

## Variables d'environnement
- `BUILD_ID` : Identifiant du build Jenkins
- `BUILD_DATE` : Date du build
EOFEOF



# Test commit Thu Dec  4 02:01:41 AM UTC 2025
