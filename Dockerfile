# NVIDIA CUDA 12.8 runtime on Ubuntu 22.04
FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

# System dependencies: Python, git, runtime libs
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv git \
    libgl1 libglib2.0-0 ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip globally
RUN python3 -m pip install --upgrade pip

# Clone AUTOMATIC1111 repo
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /workspace/stable-diffusion-webui
WORKDIR /workspace/stable-diffusion-webui

# === Extensions ===

# ADetailer: automatic face/feature detection + targeted inpainting for sharper details
RUN git clone https://github.com/Bing-su/adetailer.git \
    /workspace/stable-diffusion-webui/extensions/adetailer

# Dynamic Prompts: template-style prompts with wildcards, randomization, and combinatorics
RUN git clone https://github.com/adieyal/sd-dynamic-prompts.git \
    /workspace/stable-diffusion-webui/extensions/sd-dynamic-prompts

# ControlNet: adds pose/depth/edge guidance networks for more controllable generations
RUN git clone https://github.com/Mikubill/sd-webui-controlnet.git \
    /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet

# Civitai Helper: integrates with Civitai for model previews, metadata, and management
#RUN git clone https://github.com/butaixianran/Stable-Diffusion-Webui-Civitai-Helper.git \
#   /workspace/stable-diffusion-webui/extensions/Stable-Diffusion-Webui-Civitai-Helper

# Rembg: background removal using ONNX models (U²‑Net, ISNet, etc.)
#RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-rembg.git \
#    /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-rembg

# Tag Autocomplete: adds autocomplete for prompt tags (based on Danbooru/other tag lists)
RUN git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git \
    /workspace/stable-diffusion-webui/extensions/a1111-sd-webui-tagcomplete

# Prompt All-in-One: manage prompt presets, history, and variations in a structured way
RUN git clone https://github.com/Physton/sd-webui-prompt-all-in-one.git \
    /workspace/stable-diffusion-webui/extensions/sd-webui-prompt-all-in-one

# Image Browser: gallery tab to browse, search, and filter generated images inside WebUI
RUN git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser.git \
    /workspace/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser

# OpenPose Editor: GUI tool to draw/edit poses for ControlNet
RUN git clone https://github.com/fkunn1326/openpose-editor.git \
    /workspace/stable-diffusion-webui/extensions/openpose-editor


# Create virtual environment and install dependencies
RUN python3 -m venv /workspace/stable-diffusion-webui/venv && \
    /workspace/stable-diffusion-webui/venv/bin/pip install --upgrade pip && \
    # Install nightly Torch and torchvision first
    /workspace/stable-diffusion-webui/venv/bin/pip install --pre torch torchvision \
        --index-url https://download.pytorch.org/whl/nightly/cu128 && \
    # Install Torch-adjacent libraries before xformers
    /workspace/stable-diffusion-webui/venv/bin/pip install \
        open-clip-torch==2.20.0 \
        pytorch-lightning==1.9.4 \
        pytorch-triton==3.5.0+gitbbb06c03 \
        torchdiffeq==0.2.3 \
        torchmetrics==1.8.2 \
        torchsde==0.2.6 \
        gradio==3.41.2 \
        gradio_client==0.5.0 && \
    # Install xformers last to avoid ABI mismatches
    /workspace/stable-diffusion-webui/venv/bin/pip install --pre xformers \
        --index-url https://download.pytorch.org/whl/nightly/cu128

# Ensure hypernetworks directory exists and is owned by the mapped user
RUN mkdir -p /workspace/stable-diffusion-webui/models/hypernetworks \
    && chown -R ${USER_ID}:${GROUP_ID} /workspace/stable-diffusion-webui/models

# Environment overrides for A1111
ENV TORCH_COMMAND="echo 'Skipping torch install, already provided in venv'"
ENV COMMANDLINE_ARGS="--skip-torch-cuda-test --xformers --opt-sdp-attention --listen --port 7860 --enable-insecure-extension-access"

# Create non-root user with host-matching UID/GID for volume mounts
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} webui && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} webui && \
    chown -R webui:webui /workspace
USER webui

# Declare mount points for models and outputs
VOLUME ["/workspace/stable-diffusion-webui/models", "/workspace/stable-diffusion-webui/outputs"]

# Expose web port and start the UI
EXPOSE 7860
CMD ["/bin/bash", "-lc", "source venv/bin/activate && ./webui.sh"]
