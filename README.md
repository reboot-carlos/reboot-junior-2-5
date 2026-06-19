# 🎸 Reboot JR Chatbot - Lisa

Un chatbot multifacette avec différentes personnalités, alimenté par Claude API.

## 🚀 Installation & Démarrage

### Prérequis
- Node.js 14+ installé
- Une clé API Claude (obtiens-la sur https://console.anthropic.com)

### 1. Installer les dépendances
```bash
npm install
```

### 2. Configurer la clé API
Édite le fichier `.env` et remplace `votre_clé_api_ici` par ta vraie clé:
```
ANTHROPIC_API_KEY=sk-ant-...
```

### 3. Démarrer le serveur
```bash
npm start
```

Le serveur démarre sur `http://localhost:3000`

### 4. Ouvrir le chatbot
- Ouvre `http://localhost:3000` dans ton navigateur
- Commence à discuter avec Lisa!

## 🎭 Personnalités Disponibles
- **lisa** - Vulgaire et nonchalante (défaut)
- **Insulteur** - BRUTAL et extrêmement méchant
- **Grand-père** - Vieux bavard qui ignore les questions
- **Ultra Content** - Hyper positif et reconnaissant

Clique sur la barre latérale pour changer de personnalité!

## 🎵 Fonctionnalités
- 💬 Chat avec Claude API
- 🎸 Guitare acoustique interactive (appuie sur les frettes!)
- 🎨 Paint app
- 🎮 Mini jeux
- 🌍 Support 3 langues (FR, EN, KO)
- 🔊 Sons de guitare réalistes

## 📝 Notes
- La clé API est protégée côté serveur (pas exposée au navigateur)
- Les messages sont traités via le backend Node.js
- Tous les bruits sont générés avec la Web Audio API

---
*Crée avec ❤️ pour Reboot*
