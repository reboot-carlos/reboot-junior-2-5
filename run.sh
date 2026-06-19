#!/usr/bin/env bash
#
# run.sh — Build & lance la stack via Docker Compose
# ---------------------------------------------------
#   • Backend Node/Express   -> http://localhost:3000  (frontend + /api/chat)
#   • Backend Python/FastAPI -> http://localhost:8000  (/chat)
#
# Usage:
#   ./run.sh              # build si nécessaire, puis démarre
#   ./run.sh --build      # force le rebuild des images
#   ./run.sh --stop       # arrête et supprime les conteneurs
#   ./run.sh --logs       # affiche les logs en continu
#
# Ctrl+C arrête proprement les conteneurs.

set -euo pipefail

cd "$(dirname "$0")"

# --- Couleurs ----------------------------------------------------------------
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${GREEN}▶${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
err()  { echo -e "${RED}✖${NC} $*" >&2; }

# --- Prérequis ---------------------------------------------------------------
if ! command -v docker &>/dev/null; then
  err "Docker n'est pas installé. Installe-le sur https://docs.docker.com/get-docker/"
  exit 1
fi

if ! docker info &>/dev/null; then
  err "Le daemon Docker n'est pas démarré. Lance Docker Desktop ou 'sudo systemctl start docker'."
  exit 1
fi

# docker compose v2 (plugin) ou docker-compose v1
if docker compose version &>/dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose &>/dev/null; then
  DC="docker-compose"
else
  err "Docker Compose introuvable. Installe-le : https://docs.docker.com/compose/install/"
  exit 1
fi

# --- Vérification du .env ----------------------------------------------------
if [[ ! -f .env ]]; then
  err "Fichier .env introuvable. Crée-le avec ANTHROPIC_API_KEY=sk-ant-..."
  exit 1
fi
if ! grep -qE '^ANTHROPIC_API_KEY=sk-ant-' .env; then
  warn "ANTHROPIC_API_KEY ne semble pas configurée dans .env — les appels Claude échoueront."
fi

# --- Traitement des arguments ------------------------------------------------
BUILD_FLAG=""
case "${1:-}" in
  --build) BUILD_FLAG="--build" ;;
  --stop)
    info "Arrêt de la stack..."
    $DC down
    info "Conteneurs arrêtés."
    exit 0
    ;;
  --logs)
    $DC logs -f
    exit 0
    ;;
  "")  ;;
  *)
    err "Option inconnue: '${1}'"
    echo "Usage: $0 [--build | --stop | --logs]"
    exit 1
    ;;
esac

# --- Arrêt propre sur Ctrl+C -------------------------------------------------
cleanup() {
  echo
  info "Arrêt de la stack..."
  $DC down
  info "Stack arrêtée. À +"
}
trap cleanup INT TERM

# --- Lancement ---------------------------------------------------------------
info "Démarrage de la stack Docker..."
echo

$DC up $BUILD_FLAG &
COMPOSE_PID=$!

echo
info "Stack démarrée. Ouvre http://localhost:3000 dans ton navigateur."
info "Ctrl+C pour tout arrêter."
echo

wait $COMPOSE_PID
