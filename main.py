"""
CHATBOT BACKEND AVEC FASTAPI ET CLAUDE
================================
Ce fichier lance un serveur Python qui reçoit les questions
du chatbot et retourne les réponses de Claude.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from dotenv import load_dotenv
import anthropic
import os

# Charger les variables d'environnement depuis le fichier .env
# (sans ça, la clé ANTHROPIC_API_KEY n'est pas lue et l'API échoue)
load_dotenv()

# Créer l'application FastAPI
app = FastAPI()

# Permettre au chatbot HTML de communiquer avec ce serveur
# (sans ça, ton HTML ne peut pas appeler l'API depuis le navigateur)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permet les requêtes de n'importe où
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Créer le client Claude
# IMPORTANT: Tu dois avoir ta clé API dans une variable d'environnement
# Commande pour configurer (à faire une seule fois):
# export ANTHROPIC_API_KEY='ta-clé-api-ici'
client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

# Définir la structure des données qu'on reçoit
class Question(BaseModel):
    texte: str
    langue: str = "fr"  # français ou anglais

# ============================================================
# ENDPOINT PRINCIPAL
# Le chatbot envoie une question ici et reçoit la réponse
# ============================================================
@app.post("/chat")
async def chat(question: Question):
    """
    Reçoit une question du chatbot et retourne la réponse de Claude
    """
    try:
        # Préparer le message pour Claude
        # Lisa est un chatbot nonchalant et ironique
        systeme = """Tu es Lisa, un chatbot vert et nonchalant.
Tu parles toujours à la première personne (je, moi, mon).
Tu es ironique, cool et tu t'en fous un peu.
Tes réponses sont courtes (1-2 phrases max).
Tu trouves tout moche ou facile.
Réponds de manière désinvolte et cool."""

        # Appeler l'API Claude
        message = client.messages.create(
            model="claude-haiku-4-5-20251001",  # Modèle rapide et récent
            max_tokens=150,  # Réponses courtes
            system=systeme,
            messages=[
                {"role": "user", "content": question.texte}
            ]
        )

        # Extraire la réponse
        reponse = message.content[0].text

        # Retourner la réponse en JSON
        return {
            "success": True,
            "reponse": reponse
        }

    except Exception as e:
        # Si erreur (clé API manquante, etc)
        return {
            "success": False,
            "reponse": "Oups, y'a un souci... Réessaie?",
            "erreur": str(e)
        }

# ============================================================
# ENDPOINT DE TEST
# Pour vérifier que le serveur marche
# ============================================================
@app.get("/")
def read_root():
    return {
        "message": "Yo! Le serveur FastAPI de Lisa est actif!",
        "endpoint": "/chat (POST)",
        "exemple": "Envoie {'texte': 'Salut gros porc'} à http://localhost:8000/chat"
    }

# Servir les fichiers HTML/CSS/JS statiques (index.html, etc)
# DOIT être en dernier pour ne pas bloquer les routes API
app.mount("/", StaticFiles(directory=".", html=True), name="static")

# ============================================================
# POUR LANCER LE SERVEUR:
# uvicorn main:app --reload
#
# Puis ouvre ton chatbot dans le navigateur
# Le chatbot va maintenant appeler ce serveur au lieu d'utiliser
# la baseDeConnaissances locale
# ============================================================
