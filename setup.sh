#!/usr/bin/env bash
set -euo pipefail

# --- Safety check ---
if [ "$(id -u)" -eq 0 ]; then
  echo "[ERROR] Do not run setup.sh as root. Please run as your normal user."
  exit 1
fi

# --- Config ---
REPO_URL="https://github.com/tsondo/a1111-docker.git"
REPO_DIR="$HOME/a1111-docker"
CONTAINER_UID=1000
CONTAINER_GID=1000

echo "[INFO] Starting setup..."

# --- Parse flags ---
USE_CACHE=true
if [[ "${1:-}" == "--no-cache" ]]; then
  USE_CACHE=false
  echo "[INFO] Rebuilding container image with --no-cache"
fi

# --- Clone or update repo ---
if [ -d "$REPO_DIR/.git" ]; then
  echo "[INFO] Repo already exists, pulling latest..."
  git -C "$REPO_DIR" pull --rebase
else
  echo "[INFO] Cloning fresh repo..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

# --- Build container ---
if $USE_CACHE; then
  docker compose build
else
  docker compose build --no-cache
fi

# --- Persistent directories (must match docker-compose mounts) ---
PERSIST_DIRS=(
  configs
  models
  outputs
  extensions
  extensions/wildcards
  embeddings
  logs
  cache
  cache/huggingface
  repositories
)

echo "[INFO] Creating persistent directories..."
for d in "${PERSIST_DIRS[@]}"; do
  mkdir -p "$REPO_DIR/$d"
done

echo "[INFO] Fixing host-side ownership to match container UID:GID ($CONTAINER_UID:$CONTAINER_GID)..."
for d in "${PERSIST_DIRS[@]}"; do
  sudo chown -R "$CONTAINER_UID:$CONTAINER_GID" "$REPO_DIR/$d"
done

# --- Prepopulate UI config files if missing ---
for f in config.json ui-config.json; do
  TARGET="$REPO_DIR/configs/$f"
  if [ ! -s "$TARGET" ]; then
    echo "{}" > "$TARGET"
    echo "[INFO] Created empty $f in configs/"
  fi
done

# --- Ensure default model config exists ---
MODEL_CONFIG="$REPO_DIR/models/Stable-diffusion/v1-inference.yaml"
if [ ! -f "$MODEL_CONFIG" ]; then
  echo "[INFO] Downloading v1-inference.yaml..."
  curl -sSL -o "$MODEL_CONFIG" https://raw.githubusercontent.com/CompVis/stable-diffusion/main/configs/stable-diffusion/v1-inference.yaml
fi

# --- Launch container ---
echo "[INFO] Launching container with docker compose up..."
docker compose up
