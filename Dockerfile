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
        pytorch-triton \
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
