# NVIDIA CUDA 12.8 runtime on Ubuntu 22.04
FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

# System dependencies: Python, git, runtime libs
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv git \
    libgl1 libglib2.0-0 ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip globally
RUN python3 -m pip install --upgrade pip

# Clone AUTOMATIC1111 and sub-repos with retry and shallow depth
RUN set -eux; \
  clone_repo() { \
    local url="$1"; \
    local target="$2"; \
    local name="$3"; \
    local attempts=0; \
    until [ "$attempts" -ge 3 ]; do \
      echo "🌀 Cloning $name (attempt $((attempts+1)) of 3)..."; \
      git clone --depth 1 "$url" "$target" && break; \
      echo "❌ Clone failed for $name. Retrying in 30 seconds..."; \
      attempts=$((attempts+1)); \
      sleep 30; \
    done; \
    if [ ! -d "$target" ]; then \
      echo "🚨 Failed to clone $name after 3 attempts. Aborting build."; \
      exit 1; \
    fi; \
  }; \
  clone_repo https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /workspace/stable-diffusion-webui "WebUI"; \
  clone_repo https://github.com/crowsonkb/k-diffusion.git /workspace/stable-diffusion-webui/repositories/k-diffusion "k-diffusion"; \
  clone_repo https://github.com/CompVis/taming-transformers.git /workspace/stable-diffusion-webui/repositories/taming-transformers "taming-transformers"; \
  clone_repo https://github.com/Stability-AI/stablediffusion.git /workspace/stable-diffusion-webui/repositories/stablediffusion "stablediffusion"; \
  clone_repo https://github.com/openai/CLIP.git /workspace/stable-diffusion-webui/repositories/CLIP "CLIP"; \
  clone_repo https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git /workspace/stable-diffusion-webui/repositories/stable-diffusion-webui-assets "webui-assets"

# Set working directory
WORKDIR /workspace/stable-diffusion-webui

# Create virtual environment and install dependencies
RUN python3 -m venv /workspace/stable-diffusion-webui/venv && \
    /workspace/stable-diffusion-webui/venv/bin/pip install --upgrade pip && \
    /workspace/stable-diffusion-webui/venv/bin/pip install --pre torch torchvision \
        --index-url https://download.pytorch.org/whl/nightly/cu128 && \
    /workspace/stable-diffusion-webui/venv/bin/pip install \
        open-clip-torch==2.20.0 \
        pytorch-lightning==1.9.4 \
        pytorch-triton \
        torchdiffeq==0.2.3 \
        torchmetrics==1.8.2 \
        torchsde==0.2.6 \
        gradio==3.41.2 \
        gradio_client==0.5.0 && \
    /workspace/stable-diffusion-webui/venv/bin/pip install --pre xformers \
        --index-url https://download.pytorch.org/whl/nightly/cu128

# Ensure runtime directories are writable by the mapped user
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN mkdir -p /workspace/stable-diffusion-webui/models/hypernetworks && \
    mkdir -p /workspace/stable-diffusion-webui/cache/huggingface && \
    mkdir -p /workspace/stable-diffusion-webui/outputs && \
    mkdir -p /workspace/stable-diffusion-webui/extensions && \
    mkdir -p /workspace/stable-diffusion-webui/logs && \
    mkdir -p /workspace/stable-diffusion-webui/cache && \
    mkdir -p /workspace/stable-diffusion-webui/repositories && \
    chown -R ${USER_ID}:${GROUP_ID} /workspace/stable-diffusion-webui/models && \
    chown -R ${USER_ID}:${GROUP_ID} /workspace/stable-diffusion-webui/outputs && \
    chown -R ${USER_ID}:${GROUP_ID} /workspace/stable-diffusion-webui/extensions && \
    chown -R ${USER_ID}:${GROUP_ID} /workspace/stable-diffusion-webui/logs && \
    chown -R ${USER_ID}:${GROUP_ID} /workspace/stable-diffusion-webui/cache && \
    chown -R ${USER_ID}:${GROUP_ID} /workspace/stable-diffusion-webui/repositories

# Hugging Face cache location
ENV HF_HOME="/workspace/stable-diffusion-webui/cache/huggingface"

# Environment overrides for A1111
ENV TORCH_COMMAND="echo 'Skipping torch install, already provided in venv'"
ENV COMMANDLINE_ARGS="--skip-torch-cuda-test --xformers --opt-sdp-attention --listen --port 7860 --enable-insecure-extension-access"

# Create non-root user with host-matching UID/GID for volume mounts
RUN groupadd -g ${GROUP_ID} webui && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} webui && \
    chown -R webui:webui /workspace
USER webui

# Declare mount points for models and outputs
VOLUME ["/workspace/stable-diffusion-webui/models", "/workspace/stable-diffusion-webui/outputs"]

# Expose web port and start the UI
EXPOSE 7860
CMD ["/bin/bash", "-lc", "source venv/bin/activate && ./webui.sh"]
