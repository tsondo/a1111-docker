#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
REPO_URL="https://github.com/tsondo/a1111-docker.git"
REPO_DIR="$HOME/a1111-docker"

echo "[INFO] Starting setup..."

# --- Clone or update repo ---
if [ -d "$REPO_DIR/.git" ]; then
  echo "[INFO] Repo already exists, pulling latest..."
  git -C "$REPO_DIR" pull --rebase
else
  echo "[INFO] Cloning fresh repo..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

# --- Fix ownership immediately ---
echo "[INFO] Ensuring ownership..."
sudo chown -R "$USER:$USER" "$REPO_DIR"

# --- Persistent directories ---
PERSIST_DIRS=(
  models
  outputs
  configs
  extensions
  extensions/wildcards
  embeddings
  logs
  cache
  repositories
)

echo "[INFO] Creating persistent directories..."
for d in "${PERSIST_DIRS[@]}"; do
  mkdir -p "$REPO_DIR/$d"
done

# --- Prepopulate config files if missing or empty ---
CONFIG_DIR="$REPO_DIR/configs"
for f in config.json ui-config.json; do
  if [ ! -s "$CONFIG_DIR/$f" ]; then
    echo "{}" > "$CONFIG_DIR/$f"
    echo "[INFO] Created baseline $f"
  fi
done
echo "[INFO] Setup complete."
echo "[NEXT] cd $REPO_DIR && docker compose up -d --build"
