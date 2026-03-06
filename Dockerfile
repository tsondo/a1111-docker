# syntax=docker/dockerfile:1
# NVIDIA CUDA 12.8 runtime on Ubuntu 22.04
FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

# System dependencies: Python, git, runtime libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv git wget \
    libgl1 libglib2.0-0 ffmpeg \
    libgoogle-perftools-dev curl && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user early so venv is owned correctly from the start
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} webui && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} webui

# Set up workspace directory with correct ownership
RUN mkdir -p /workspace/stable-diffusion-webui && \
    chown webui:webui /workspace/stable-diffusion-webui

WORKDIR /workspace/stable-diffusion-webui

# Switch to non-root user for all subsequent steps
USER webui

# Create virtual environment
RUN python3 -m venv venv

# Layer 1 (heavy, rarely changes): Torch + CUDA wheels
RUN --mount=type=cache,target=/home/webui/.cache/pip,uid=${USER_ID},gid=${GROUP_ID} \
    venv/bin/pip install --upgrade pip && \
    venv/bin/pip install torch torchvision \
        --index-url https://download.pytorch.org/whl/cu128

# Layer 2 (medium, changes occasionally): xformers + ML deps
RUN --mount=type=cache,target=/home/webui/.cache/pip,uid=${USER_ID},gid=${GROUP_ID} \
    venv/bin/pip install \
        xformers \
        open-clip-torch==2.20.0 \
        pytorch-lightning==1.9.4 \
        pytorch-triton \
        torchdiffeq==0.2.3 \
        torchmetrics==1.8.2 \
        torchsde==0.2.6 \
        jax==0.6.2 \
        jaxlib==0.6.2 \
        ml_dtypes==0.5.3

# Layer 3 (lighter, changes more often): UI + extension deps
RUN --mount=type=cache,target=/home/webui/.cache/pip,uid=${USER_ID},gid=${GROUP_ID} \
    venv/bin/pip install \
        gradio==3.41.2 \
        gradio_client==0.5.0 \
        opencv-contrib-python==4.11.0.86 \
        polars==1.35.2 \
        mediapipe \
        ultralytics

# Clone AUTOMATIC1111 and sub-repos with retry
RUN set -eux; \
  clone_repo() { \
    local url="$1"; \
    local target="$2"; \
    local name="$3"; \
    local attempts=0; \
    until [ "$attempts" -ge 3 ]; do \
      echo "Cloning $name (attempt $((attempts+1)) of 3)..."; \
      git clone --depth 1 "$url" "$target" && return 0; \
      echo "Clone failed for $name. Retrying in 30 seconds..."; \
      attempts=$((attempts+1)); \
      sleep 30; \
    done; \
    echo "Failed to clone $name after 3 attempts. Aborting build."; \
    exit 1; \
  }; \
  clone_repo https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /tmp/a1111-src "WebUI" && \
  cp -a /tmp/a1111-src/. /workspace/stable-diffusion-webui/ && \
  rm -rf /tmp/a1111-src/.git; \
  clone_repo https://github.com/crowsonkb/k-diffusion.git repositories/k-diffusion "k-diffusion"; \
  clone_repo https://github.com/CompVis/taming-transformers.git repositories/taming-transformers "taming-transformers"; \
  clone_repo https://github.com/w-e-w/stablediffusion.git repositories/stablediffusion "stablediffusion"; \
  clone_repo https://github.com/openai/CLIP.git repositories/CLIP "CLIP"; \
  clone_repo https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git repositories/stable-diffusion-webui-assets "webui-assets"

# Create runtime directories that may not exist in the repo
RUN mkdir -p cache/huggingface cache/matplotlib models/hypernetworks

# Environment configuration
ENV HF_HOME="/workspace/stable-diffusion-webui/cache/huggingface"
ENV PIP_CACHE_DIR="/workspace/stable-diffusion-webui/pip-cache"
ENV TORCH_COMMAND="echo 'Skipping torch install, already provided in venv'"

# Health check: wait for Gradio to respond
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:7860/ || exit 1

EXPOSE 7860
CMD ["/bin/bash", "-lc", "source venv/bin/activate && ./webui.sh"]
