# 🚀 COMMENT BRANCHER TON CHATBOT À CLAUDE

## ÉTAPE 1 : Installe les libs Python

Ouvre ton terminal et tape :
```bash
pip install fastapi uvicorn anthropic python-dotenv
```

## ÉTAPE 2 : Configure ta clé API Claude

1. Va sur https://console.anthropic.com
2. Crée un compte et génère une clé API
3. Ouvre ton terminal et tape (remplace par ta vraie clé) :
```bash
export ANTHROPIC_API_KEY='sk-ant-xxxxxxxxxxxxx'
```

**Sur Windows :** 
```cmd
set ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx
```

## ÉTAPE 3 : Lance le serveur FastAPI

Dans le terminal, va dans ton dossier et tape :
```bash
uvicorn main:app --reload
```

Tu devrais voir :
```
Uvicorn running on http://127.0.0.1:8000
```

✅ Le serveur tourne!

## ÉTAPE 4 : Modifie ton chatbot pour utiliser Claude

**IMPORTANT:** Je vais te dire EXACTEMENT quoi changer dans ton `index.html`

Trouve cette fonction (ligne ~410 environ) :

```javascript
async function traiterQuestion(q) {
  const knowledge = baseDeConnaissances[currentLanguage];
  for (const entree of knowledge) {
    if (contient(q, entree.mots)) {
      return typeof entree.reponse === 'function' ? entree.reponse() : entree.reponse;
    }
  }

  const defaultMsg = currentLanguage === 'fr'
    ? 'Honnêtement, j\'ai pas compris ce que tu disais. Envoie un truc plus clair?'
    : 'Honestly, I didn\'t really get what you said. Send me something clearer?';

  return defaultMsg;
}
```

**Remplace-la par ça :**

```javascript
async function traiterQuestion(q) {
  try {
    // Appelle Claude via FastAPI
    const response = await fetch('http://localhost:8000/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        texte: q,
        langue: currentLanguage
      })
    });

    const data = await response.json();

    if (data.success) {
      return data.reponse;
    } else {
      return "Oups, Claude n'a pas répondu...";
    }
  } catch (error) {
    console.error('Erreur:', error);
    return "Le serveur Python n'est pas actif... Lance: uvicorn main:app --reload";
  }
}
```

## ÉTAPE 5 : Teste !

1. Ouvre ton `index.html` dans le navigateur
2. Écris une question
3. Lisa va répondre avec Claude ! 🤖

## ✅ Et voilà !

Ton chatbot utilise maintenant :
- **Frontend** : HTML/CSS/JS (ton code original - inchangé!)
- **Backend** : FastAPI (main.py)
- **IA** : Claude d'Anthropic

## 🐛 Troubleshooting

**"Erreur: Cannot POST /chat"**
→ Assurez-vous que `uvicorn main:app --reload` est actif

**"ANTHROPIC_API_KEY not found"**
→ T'as pas configuré ta clé API (relire ÉTAPE 2)

**"Connection refused"**
→ Le serveur n'est pas lancé (relire ÉTAPE 3)

Des questions ? 🎯
