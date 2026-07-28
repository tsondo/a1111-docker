# syntax=docker/dockerfile:1
# Default: NVIDIA CUDA 12.8 runtime on Ubuntu 22.04.
# The ROCm variant overrides BASE_IMAGE, TORCH_INDEX_URL, and
# INSTALL_XFORMERS (see docker-compose.rocm.yml) — PyTorch's ROCm wheels
# bundle the ROCm runtime, so a plain Ubuntu base is enough there.
ARG BASE_IMAGE=nvidia/cuda:12.8.0-runtime-ubuntu22.04
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/tsondo/a1111-docker"
LABEL org.opencontainers.image.description="AUTOMATIC1111 Stable Diffusion WebUI with CUDA 12.8, ready to run"

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

# Layer 1 (heavy, rarely changes): Torch GPU wheels.
# Pinned: newer torch/torchvision pull in numpy 2, which conflicts with
# A1111 v1.10.1's numpy==1.26.2 pin and makes pip silently replace torch
# with a PyPI (CUDA) build during the requirements install.
ARG TORCH_INDEX_URL=https://download.pytorch.org/whl/cu128
RUN --mount=type=cache,target=/home/webui/.cache/pip,uid=${USER_ID},gid=${GROUP_ID} \
    venv/bin/pip install --upgrade pip "setuptools<81" && \
    venv/bin/pip install torch==2.10.0 torchvision==0.25.0 \
        --index-url ${TORCH_INDEX_URL}

# Layer 2 (medium, changes occasionally): xformers + ML deps
# xformers is CUDA-only; the ROCm variant skips it and uses
# --opt-sdp-attention at runtime instead.
ARG INSTALL_XFORMERS=true
RUN --mount=type=cache,target=/home/webui/.cache/pip,uid=${USER_ID},gid=${GROUP_ID} \
    if [ "${INSTALL_XFORMERS}" = "true" ]; then venv/bin/pip install xformers; fi && \
    venv/bin/pip install \
        open-clip-torch==2.20.0 \
        pytorch-lightning==1.9.4 \
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

# Old-style packages (e.g. openai/CLIP) import pkg_resources at build
# time, which setuptools>=81 removed. The venv pins setuptools<81, but
# pip's isolated build environments install the latest setuptools unless
# constrained — PIP_CONSTRAINT reaches inside them, and also covers
# packages that extensions install at runtime.
# Also freeze the installed torch/torchvision versions (minus the
# +cu/+rocm local suffix, which constraint files reject) so no later pip
# run — A1111's requirements install or an extension — can swap the GPU
# stack for a different build. A conflict now fails the build loudly
# instead of silently replacing torch.
RUN echo "setuptools<81" > /home/webui/pip-constraints.txt && \
    venv/bin/pip freeze | grep -E '^(torch|torchvision)==' | sed 's/+.*$//' >> /home/webui/pip-constraints.txt && \
    cat /home/webui/pip-constraints.txt
ENV PIP_CONSTRAINT="/home/webui/pip-constraints.txt"

# Fetch AUTOMATIC1111 at a pinned release. Bump A1111_VERSION to upgrade.
# In-place init+fetch because the workdir already contains venv/.
ARG A1111_VERSION=v1.10.1
RUN set -eux; \
    git init .; \
    git remote add origin https://github.com/AUTOMATIC1111/stable-diffusion-webui.git; \
    for i in 1 2 3; do \
      if git fetch --depth 1 origin tag "${A1111_VERSION}"; then break; fi; \
      if [ "$i" = 3 ]; then echo "Failed to fetch A1111 after 3 attempts."; exit 1; fi; \
      echo "Fetch failed (attempt $i of 3). Retrying in 15 seconds..."; \
      sleep 15; \
    done; \
    git -c advice.detachedHead=false checkout -f "${A1111_VERSION}"

# Stability-AI deleted their stablediffusion repo; use a fork that
# still contains the commit A1111 pins (cf1d67a6).
ENV STABLE_DIFFUSION_REPO="https://github.com/w-e-w/stablediffusion.git"

# Let A1111's own launcher prepare everything at build time: it clones
# the sub-repos (stablediffusion, generative-models, k-diffusion, BLIP,
# assets) at the exact commits this release expects and installs the
# remaining Python requirements. First container start then needs no
# network access at all.
RUN --mount=type=cache,target=/home/webui/.cache/pip,uid=${USER_ID},gid=${GROUP_ID} \
    venv/bin/python launch.py --skip-torch-cuda-test --exit

# Create runtime directories that may not exist in the repo
RUN mkdir -p cache/huggingface cache/matplotlib models/hypernetworks

# Environment configuration
ENV HF_HOME="/workspace/stable-diffusion-webui/cache/huggingface"
ENV MPLCONFIGDIR="/workspace/stable-diffusion-webui/cache/matplotlib"
ENV PIP_CACHE_DIR="/workspace/stable-diffusion-webui/pip-cache"
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc.so"

# Health check: wait for Gradio to respond. Generous start period —
# first launch loads a model into VRAM, which can take a few minutes.
HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=3 \
  CMD curl -f http://localhost:7860/ || exit 1

EXPOSE 7860
CMD ["/bin/bash", "-lc", "source venv/bin/activate && ./webui.sh"]
