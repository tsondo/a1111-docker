#!/usr/bin/env bash
set -euo pipefail

# --- Safety check ---
if [ "$(id -u)" -eq 0 ]; then
  echo "[ERROR] Do not run setup.sh as root. Please run as your normal user."
  exit 1
fi

# --- Dependency checks ---
missing=()
for cmd in git docker curl; do
  if ! command -v "$cmd" &>/dev/null; then
    missing+=("$cmd")
  fi
done
if ! docker compose version &>/dev/null 2>&1; then
  missing+=("docker-compose-plugin")
fi
if [ ${#missing[@]} -gt 0 ]; then
  echo "[ERROR] Missing required tools: ${missing[*]}"
  echo "        See README.md for installation instructions."
  exit 1
fi

# --- NVIDIA Container Toolkit check ---
if ! docker info 2>/dev/null | grep -qi nvidia; then
  echo "[WARNING] NVIDIA runtime not detected in Docker."
  echo "          GPU passthrough may fail. Install the NVIDIA Container Toolkit:"
  echo "          https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
  echo ""
  read -rp "Continue anyway? [y/N] " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    exit 0
  fi
fi

# --- Config ---
REPO_URL="https://github.com/tsondo/a1111-docker.git"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER_UID=1000
CONTAINER_GID=1000

# Ensure .env exists
if [ ! -f "$REPO_DIR/.env" ]; then
  echo "[INFO] No .env file found. Copying from .env.sample..."
  cp "$REPO_DIR/.env.sample" "$REPO_DIR/.env"
fi

# Migrate old .env variable names to new ones
if grep -q '^REPO_DIR=' "$REPO_DIR/.env" 2>/dev/null; then
  echo "[INFO] Migrating .env: REPO_DIR -> REPOSITORIES_DIR"
  sed -i 's/^REPO_DIR=/REPOSITORIES_DIR=/' "$REPO_DIR/.env"
fi
if grep -q '^HF_MODELS_PATH=' "$REPO_DIR/.env" 2>/dev/null; then
  echo "[INFO] Migrating .env: HF_MODELS_PATH -> HF_MODELS_DIR"
  sed -i 's/^HF_MODELS_PATH=/HF_MODELS_DIR=/' "$REPO_DIR/.env"
fi
if grep -q '^WILDCARD_DIR=' "$REPO_DIR/.env" 2>/dev/null; then
  echo "[INFO] Migrating .env: removing unused WILDCARD_DIR"
  sed -i '/^WILDCARD_DIR=/d' "$REPO_DIR/.env"
fi

echo "[INFO] Starting setup..."

# --- Parse flags ---
USE_CACHE=true
DETACH=false
for arg in "$@"; do
  case "$arg" in
    --no-cache) USE_CACHE=false; echo "[INFO] Rebuilding container image with --no-cache" ;;
    -d|--detach) DETACH=true ;;
  esac
done

# --- Clone or update repo ---
if [ -d "$REPO_DIR/.git" ]; then
  echo "[INFO] Repo already exists..."

  current_branch=$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD)

  if [ "$current_branch" = "main" ]; then
    echo "[INFO] On main branch, pulling latest..."
    OLD_HASH=$(git -C "$REPO_DIR" rev-parse HEAD:setup.sh 2>/dev/null || echo "none")
    git -C "$REPO_DIR" pull --ff-only || {
      echo "[WARNING] Fast-forward pull failed (upstream has diverged or there are local changes)."
      echo "          Skipping update — resolve manually with: git -C $REPO_DIR pull"
    }
    NEW_HASH=$(git -C "$REPO_DIR" rev-parse HEAD:setup.sh 2>/dev/null || echo "none")
    if [ "$OLD_HASH" != "$NEW_HASH" ]; then
      echo "[INFO] setup.sh was updated during pull. Please re-run it to apply changes."
      exit 0
    fi
  else
    echo "[INFO] On branch '$current_branch', skipping git pull to preserve local changes."
  fi
else
  echo "[INFO] Cloning fresh repo..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

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
  pip-cache
  hf_models
)

echo "[INFO] Creating persistent directories..."
for d in "${PERSIST_DIRS[@]}"; do
  mkdir -p "$REPO_DIR/$d"
done

# Fix ownership only for directories that don't already match the container UID:GID.
needs_chown=false
for d in "${PERSIST_DIRS[@]}"; do
  dir_uid=$(stat -c '%u' "$REPO_DIR/$d")
  dir_gid=$(stat -c '%g' "$REPO_DIR/$d")
  if [ "$dir_uid" != "$CONTAINER_UID" ] || [ "$dir_gid" != "$CONTAINER_GID" ]; then
    needs_chown=true
    break
  fi
done

if $needs_chown; then
  echo "[INFO] Fixing host-side ownership to match container UID:GID ($CONTAINER_UID:$CONTAINER_GID)..."
  for d in "${PERSIST_DIRS[@]}"; do
    sudo chown "$CONTAINER_UID:$CONTAINER_GID" "$REPO_DIR/$d"
  done
else
  echo "[INFO] Directory ownership already correct, skipping chown."
fi

# --- Prepopulate UI config files if missing ---
for f in config.json ui-config.json; do
  TARGET="$REPO_DIR/$f"
  if [ ! -s "$TARGET" ]; then
    echo "{}" > "$TARGET"
    echo "[INFO] Created empty $f in repo root"
  fi
done

# styles.csv needs a valid CSV header, not JSON
if [ ! -s "$REPO_DIR/styles.csv" ]; then
  echo "name,prompt,negative_prompt" > "$REPO_DIR/styles.csv"
  echo "[INFO] Created styles.csv with header row"
fi

# --- Ensure default model config exists in expected path ---
CONFIG_PATH="$REPO_DIR/configs/v1-inference.yaml"
if [ ! -f "$CONFIG_PATH" ]; then
  echo "[INFO] Downloading v1-inference.yaml to configs/"
  curl -fsSL -o "$CONFIG_PATH" https://raw.githubusercontent.com/CompVis/stable-diffusion/main/configs/stable-diffusion/v1-inference.yaml || {
    echo "[WARNING] Failed to download v1-inference.yaml. You may need to add it manually."
    rm -f "$CONFIG_PATH"
  }
fi

# --- Build container ---
if $USE_CACHE; then
  docker compose build
else
  docker compose build --no-cache
fi

# --- Launch container ---
if $DETACH; then
  echo "[INFO] Launching container in background..."
  docker compose up -d
  echo "[INFO] WebUI starting at http://localhost:7860"
  echo "       View logs: docker compose logs -f"
  echo "       Stop:      docker compose down"
else
  echo "[INFO] Launching container (Ctrl+C to stop)..."
  docker compose up
fi
