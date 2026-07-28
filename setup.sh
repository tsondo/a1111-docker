#!/usr/bin/env bash
set -euo pipefail

# --- Safety check ---
if [ "$(id -u)" -eq 0 ]; then
  echo "[ERROR] Do not run setup.sh as root. Please run as your normal user."
  exit 1
fi

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_ID="$(id -u)"
GROUP_ID="$(id -g)"

# --- Parse flags ---
USE_CACHE=true
DETACH=false
PULL=false
VARIANT=auto
for arg in "$@"; do
  case "$arg" in
    --no-cache) USE_CACHE=false; echo "[INFO] Rebuilding container image with --no-cache" ;;
    -d|--detach) DETACH=true ;;
    --pull) PULL=true ;;
    --rocm) VARIANT=rocm ;;
    --nvidia) VARIANT=nvidia ;;
    -h|--help)
      echo "Usage: setup.sh [--pull] [--no-cache] [-d|--detach] [--rocm|--nvidia]"
      echo "  --pull       Pull the prebuilt image from GHCR instead of building locally"
      echo "  --no-cache   Build the image from scratch, ignoring Docker's cache"
      echo "  -d, --detach Run the container in the background"
      echo "  --rocm       Force the AMD GPU (ROCm) variant"
      echo "  --nvidia     Force the NVIDIA GPU (CUDA) variant"
      echo "  (default: auto-detect — AMD if /dev/kfd exists, NVIDIA otherwise)"
      exit 0
      ;;
  esac
done

# --- Pick GPU variant ---
if [ "$VARIANT" = "auto" ]; then
  if [ -e /dev/kfd ]; then
    VARIANT=rocm
    echo "[INFO] AMD GPU detected (/dev/kfd) — using the ROCm variant."
  else
    VARIANT=nvidia
  fi
fi

COMPOSE=(docker compose)
if [ "$VARIANT" = "rocm" ]; then
  COMPOSE=(docker compose -f docker-compose.rocm.yml)
fi

# --- Dependency checks ---
if ! command -v docker &>/dev/null; then
  echo "[ERROR] Docker is not installed. See HOWTO.md for installation instructions."
  exit 1
fi
if ! docker compose version &>/dev/null 2>&1; then
  echo "[ERROR] The Docker Compose plugin is missing. See HOWTO.md for installation instructions."
  exit 1
fi

# --- GPU runtime checks ---
if [ "$VARIANT" = "nvidia" ]; then
  if ! docker info 2>/dev/null | grep -qi nvidia; then
    echo "[WARNING] NVIDIA runtime not detected in Docker."
    echo "          GPU passthrough may fail. Install the NVIDIA Container Toolkit:"
    echo "          See HOWTO.md, or https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
    echo "          (AMD GPU? Re-run with: bash setup.sh --rocm)"
    echo ""
    read -rp "Continue anyway? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
      exit 0
    fi
  fi
else
  if [ ! -e /dev/kfd ]; then
    echo "[WARNING] /dev/kfd not found — the amdgpu driver doesn't appear to be loaded."
    echo "          GPU passthrough will fail. Note: ROCm requires native Linux (not WSL2)."
    echo ""
    read -rp "Continue anyway? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
      exit 0
    fi
  fi
fi

echo "[INFO] Starting setup..."
cd "$REPO_DIR"

# --- Ensure .env exists ---
if [ ! -f .env ]; then
  echo "[INFO] No .env file found. Copying from .env.sample..."
  cp .env.sample .env
fi

# --- Migrate obsolete .env variables ---
# These directories are no longer mounted: the container image now ships
# its own repositories/ and configs/, and the HuggingFace cache lives
# under cache/huggingface.
for var in REPO_DIR HF_MODELS_PATH WILDCARD_DIR REPOSITORIES_DIR HF_MODELS_DIR CONFIG_DIR; do
  if grep -q "^${var}=" .env 2>/dev/null; then
    echo "[INFO] Migrating .env: removing obsolete ${var}"
    sed -i "/^${var}=/d" .env
  fi
done

# --- Record the host user's UID/GID for the image build ---
ENV_PAIRS=("USER_ID:$USER_ID" "GROUP_ID:$GROUP_ID")

# ROCm: the container needs the host's video/render group IDs to access
# /dev/kfd and /dev/dri. These GIDs vary by distro, so record the real ones.
if [ "$VARIANT" = "rocm" ]; then
  video_gid=$(getent group video | cut -d: -f3 || true)
  render_gid=$(getent group render | cut -d: -f3 || true)
  [ -n "$video_gid" ] && ENV_PAIRS+=("VIDEO_GID:$video_gid")
  [ -n "$render_gid" ] && ENV_PAIRS+=("RENDER_GID:$render_gid")
fi

for pair in "${ENV_PAIRS[@]}"; do
  var="${pair%%:*}"; val="${pair##*:}"
  if grep -q "^${var}=" .env; then
    sed -i "s/^${var}=.*/${var}=${val}/" .env
  else
    echo "${var}=${val}" >> .env
  fi
done

# --- Migrate HuggingFace cache from the old hf_models/ location ---
for old_hf in hf_models HF_models; do
  if [ -d "$old_hf" ] && [ -n "$(ls -A "$old_hf" 2>/dev/null)" ]; then
    echo "[INFO] Migrating $old_hf/ contents to cache/huggingface/ (new location)..."
    mkdir -p cache/huggingface
    for f in "$old_hf"/* "$old_hf"/.[!.]*; do
      [ -e "$f" ] || continue
      base="$(basename "$f")"
      if [ -e "cache/huggingface/$base" ]; then
        echo "[WARNING] cache/huggingface/$base already exists, leaving $f in place."
      else
        mv "$f" cache/huggingface/
      fi
    done
    rmdir "$old_hf" 2>/dev/null && echo "[INFO] Removed empty $old_hf/" || true
  fi
done

# --- Notes about directories that are no longer mounted ---
if [ -d repositories ] && [ -n "$(ls -A repositories 2>/dev/null)" ]; then
  echo "[INFO] The repositories/ folder is no longer used (the image ships its own copies)."
  echo "       You can delete it to free space: rm -rf repositories/"
fi
if [ -d configs ]; then
  extra_configs=$(find configs -type f ! -name 'v1-inference.yaml' 2>/dev/null | head -1)
  if [ -n "$extra_configs" ]; then
    echo "[WARNING] configs/ is no longer mounted into the container."
    echo "          Custom model .yaml files should sit next to their checkpoint in models/Stable-diffusion/."
  fi
fi

# --- Persistent directories (must match docker-compose mounts) ---
PERSIST_DIRS=(
  models
  outputs
  extensions
  extensions/wildcards
  embeddings
  logs
  cache
  cache/huggingface
  pip-cache
)

echo "[INFO] Creating persistent directories..."
for d in "${PERSIST_DIRS[@]}"; do
  mkdir -p "$d"
done

# Fix ownership only for directories that don't already match the user.
needs_chown=false
for d in "${PERSIST_DIRS[@]}"; do
  dir_uid=$(stat -c '%u' "$d")
  dir_gid=$(stat -c '%g' "$d")
  if [ "$dir_uid" != "$USER_ID" ] || [ "$dir_gid" != "$GROUP_ID" ]; then
    needs_chown=true
    break
  fi
done

if $needs_chown; then
  echo "[INFO] Fixing host-side ownership to $USER_ID:$GROUP_ID..."
  for d in "${PERSIST_DIRS[@]}"; do
    sudo chown "$USER_ID:$GROUP_ID" "$d"
  done
else
  echo "[INFO] Directory ownership already correct, skipping chown."
fi

# --- Prepopulate UI config files if missing ---
# These are mounted as single files, so they must exist before "up".
for f in config.json ui-config.json; do
  if [ ! -s "$f" ]; then
    echo "{}" > "$f"
    echo "[INFO] Created empty $f in repo root"
  fi
done

# styles.csv needs a valid CSV header, not JSON
if [ ! -s styles.csv ]; then
  echo "name,prompt,negative_prompt" > styles.csv
  echo "[INFO] Created styles.csv with header row"
fi

# --- Build or pull the image ---
if $PULL; then
  echo "[INFO] Pulling prebuilt image from GHCR..."
  if ! "${COMPOSE[@]}" pull; then
    echo "[WARNING] Pull failed (no published image, or no network). Building locally instead..."
    "${COMPOSE[@]}" build
  fi
elif $USE_CACHE; then
  "${COMPOSE[@]}" build
else
  "${COMPOSE[@]}" build --no-cache
fi

# --- Launch container ---
if $DETACH; then
  echo "[INFO] Launching container in background..."
  "${COMPOSE[@]}" up -d
  echo "[INFO] WebUI starting at http://localhost:7860"
  echo "       View logs: ${COMPOSE[*]} logs -f"
  echo "       Stop:      ${COMPOSE[*]} down"
else
  echo "[INFO] Launching container (Ctrl+C to stop)..."
  "${COMPOSE[@]}" up
fi
