require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static('.'));

const CLAUDE_API_KEY = process.env.ANTHROPIC_API_KEY;

if (!CLAUDE_API_KEY) {
  console.error('❌ ERREUR: ANTHROPIC_API_KEY non trouvée dans .env');
  process.exit(1);
}

app.post('/api/chat', async (req, res) => {
  try {
    const { message, systemPrompt, maxTokens = 300 } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message requis' });
    }

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': CLAUDE_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-opus-4-8',
        max_tokens: maxTokens,
        system: systemPrompt,
        messages: [
          { role: 'user', content: message }
        ]
      })
    });

    const data = await response.json();

    if (data.content && data.content[0]) {
      res.json({ response: data.content[0].text });
    } else if (data.error) {
      res.status(500).json({ error: data.error.message });
    } else {
      res.status(500).json({ error: 'Pas de réponse de Claude' });
    }
  } catch (error) {
    console.error('Erreur serveur:', error);
    res.status(500).json({ error: 'Erreur de connexion à Claude' });
  }
});

app.listen(PORT, () => {
  console.log(`🎸 Serveur démarré sur http://localhost:${PORT}`);
  console.log(`✅ Clé API Claude chargée depuis .env`);
});
