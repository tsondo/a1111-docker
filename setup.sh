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

# --- Clone or update repo ---
if [ -d "$REPO_DIR/.git" ]; then
  echo "[INFO] Repo already exists, pulling latest..."
  git -C "$REPO_DIR" pull --rebase
else
  echo "[INFO] Cloning fresh repo..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

# --- Build container first ---
echo "[INFO] Building container image..."
docker compose build

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
    echo "[INFO] Created baseline $f"
  fi
done

# --- Fetch all known model config files ---
declare -A CONFIG_URLS=(
  ["v1-inference.yaml"]="https://raw.githubusercontent.com/CompVis/stable-diffusion/main/configs/stable-diffusion/v1-inference.yaml"
  ["v2-inference.yaml"]="https://raw.githubusercontent.com/Stability-AI/stablediffusion/main/configs/stable-diffusion/v2-inference.yaml"
  ["v1-inpainting.yaml"]="https://raw.githubusercontent.com/CompVis/stable-diffusion/main/configs/stable-diffusion/v1-inpainting.yaml"
  ["v2-inpainting.yaml"]="https://raw.githubusercontent.com/Stability-AI/stablediffusion/main/configs/stable-diffusion/v2-inpainting.yaml"
  ["sdxl.yaml"]="https://raw.githubusercontent.com/Stability-AI/generative-models/main/configs/stable-diffusion/sdxl.yaml"
  ["sdxl-refiner.yaml"]="https://raw.githubusercontent.com/Stability-AI/generative-models/main/configs/stable-diffusion/sdxl-refiner.yaml"
)

echo "[INFO] Ensuring all model config files are present in ./configs..."
for filename in "${!CONFIG_URLS[@]}"; do
  TARGET="$REPO_DIR/configs/$filename"
  if [ ! -f "$TARGET" ]; then
    echo "[FETCH] $filename..."
    wget -q "${CONFIG_URLS[$filename]}" -O "$TARGET" && echo "[OK] $filename downloaded"
  else
    echo "[SKIP] $filename already exists"
  fi
done

# --- Launch container ---
echo "[INFO] Launching WebUI..."
docker compose up
