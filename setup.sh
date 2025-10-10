#!/usr/bin/env bash
set -euo pipefail
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

# --- Clone or update repo ---
if [ -d "$REPO_DIR/.git" ]; then
  echo "[INFO] Repo already exists, pulling latest..."
  git -C "$REPO_DIR" pull --rebase
else
  echo "[INFO] Cloning fresh repo..."
  git clone "$REPO_URL" "$REPO_DIR"
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

# --- Prepopulate config files if missing or empty ---
for f in config.json ui-config.json; do
  TARGET="$REPO_DIR/configs/$f"
  if [ ! -s "$TARGET" ]; then
    echo "{}" > "$TARGET"
    echo "[INFO] Created baseline $f"
  fi
done

# --- Build and launch ---
echo "[INFO] Setup complete."
cd "$REPO_DIR"
echo "[INFO] Building container (no cache)..."
docker compose build --no-cache
echo "[INFO] Launching WebUI..."
docker compose up
