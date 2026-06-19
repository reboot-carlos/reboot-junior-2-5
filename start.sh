#!/usr/bin/env bash
#
# start.sh — Lance toute la stack Reboot JR Chatbot
# -------------------------------------------------
#   • Backend Node/Express  (server.js)  -> http://localhost:3000  (frontend + /api/chat)
#   • Backend Python/FastAPI (main.py)   -> http://localhost:8000  (/chat)
#
# Usage:
#   ./start.sh            # lance les deux backends
#   ./start.sh node       # lance uniquement le backend Node
#   ./start.sh python     # lance uniquement le backend Python
#
# Ctrl+C arrête proprement les deux serveurs.

set -euo pipefail

# Se placer dans le dossier du script (peu importe d'où on l'appelle)
cd "$(dirname "$0")"

TARGET="${1:-all}"   # all | node | python

# --- Couleurs ---------------------------------------------------------------
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}▶${NC} $*"; }
warn()  { echo -e "${YELLOW}⚠${NC}  $*"; }
err()   { echo -e "${RED}✖${NC} $*" >&2; }

# --- Vérification du .env ----------------------------------------------------
if [[ ! -f .env ]]; then
  err "Fichier .env introuvable. Crée-le avec ANTHROPIC_API_KEY=sk-ant-..."
  exit 1
fi
if ! grep -qE '^ANTHROPIC_API_KEY=sk-ant-' .env; then
  warn "ANTHROPIC_API_KEY ne semble pas configurée dans .env — les appels Claude échoueront."
fi

PIDS=()

# Arrêt propre des deux serveurs sur Ctrl+C / fin de script
cleanup() {
  echo
  info "Arrêt de la stack..."
  for pid in "${PIDS[@]:-}"; do
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
  done
  wait 2>/dev/null || true
  info "Stack arrêtée. À +"
}
trap cleanup INT TERM EXIT

# --- Backend Node -----------------------------------------------------------
start_node() {
  if ! command -v node >/dev/null 2>&1; then
    err "Node.js n'est pas installé."; exit 1
  fi
  if [[ ! -d node_modules ]]; then
    info "Installation des dépendances Node (npm install)..."
    npm install
  fi
  info "Backend Node    -> http://localhost:3000  (frontend + /api/chat)"
  node server.js &
  PIDS+=("$!")
}

# --- Backend Python ---------------------------------------------------------
start_python() {
  # Choisir l'interpréteur python disponible
  local PY=""
  for cand in python3 python; do
    command -v "$cand" >/dev/null 2>&1 && { PY="$cand"; break; }
  done
  if [[ -z "$PY" ]]; then
    err "Python n'est pas installé."; exit 1
  fi
  # Vérifier les dépendances ; les installer si besoin
  if ! "$PY" -c "import fastapi, uvicorn, anthropic, dotenv" >/dev/null 2>&1; then
    info "Installation des dépendances Python..."
    "$PY" -m pip install --quiet fastapi uvicorn anthropic python-dotenv
  fi
  info "Backend Python  -> http://localhost:8000  (/chat)"
  "$PY" -m uvicorn main:app --host 0.0.0.0 --port 8000 &
  PIDS+=("$!")
}

# --- Lancement selon la cible -----------------------------------------------
case "$TARGET" in
  node)   start_node ;;
  python) start_python ;;
  all)    start_node; start_python ;;
  *)      err "Cible inconnue: '$TARGET' (utilise: all | node | python)"; exit 1 ;;
esac

echo
info "Stack démarrée. Ouvre http://localhost:3000 dans ton navigateur."
info "Ctrl+C pour tout arrêter."
echo

# Attendre les processus ; si l'un meurt, le trap nettoie l'autre
wait
