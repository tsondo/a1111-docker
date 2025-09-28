![Build](https://img.shields.io/badge/build-passing-brightgreen)
![CUDA](https://img.shields.io/badge/CUDA-12.8-blue)
![GPU](https://img.shields.io/badge/GPU-NVIDIA%20enabled-yellowgreen)
![WSL2](https://img.shields.io/badge/WSL2-supported-green)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Volumes](https://img.shields.io/badge/volumes-modular%20%26%20persistent-blueviolet)
![Extensions](https://img.shields.io/badge/extensions-webUI%20managed-orange)
![Snapshot](https://img.shields.io/badge/snapshots-not%20required-lightgrey)
![Tested](https://img.shields.io/badge/tested-4080%20%7C%205090-green)
![License](https://img.shields.io/github/license/tsondo/a1111-docker)


# 🚀 Automatic1111 in Docker (GPU‑accelerated)

This repo wraps [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) in a reproducible Docker setup with GPU support.  
It’s designed for persistent use: your models, outputs, wildcards, and extensions live outside the container and are mounted in at runtime.

---

## 📦 Requirements

- **Windows 11**: Docker Desktop with WSL2 backend and Ubuntu 22.04 installed
- **Linux**: Docker Engine with NVIDIA runtime

---

## 🖥️ Windows 11 Setup

1. **Install WSL2 with Ubuntu 22.04**  
   Open PowerShell as Administrator and run:  
   ```powershell
   wsl --install -d Ubuntu-22.04
   ```

2. **Install Docker Desktop**  
   Download from [docker.com](https://www.docker.com/products/docker-desktop) and complete setup.

3. **Enable WSL Integration**  
   Docker Desktop → Settings → Resources → WSL Integration  
   Enable for your Ubuntu distro (`Ubuntu-22.04`)

4. **Open your WSL shell**  
   Press `Windows + S`, type `Ubuntu`, and launch the app.  
   You’ll land in your Linux home (e.g., `/home/todd`)

5. **Run Docker commands inside WSL**  
   Always use the WSL shell to run:
   ```bash
   docker compose up -d
   ```

6. **(Optional) Install CUDA for other projects**  
   Not required for this container — it includes its own CUDA runtime.  
   If you want CUDA in WSL for other tools:
   ```bash
   nvidia-smi
   ```

---

Here’s the revised and bulletproof version of your **⚙️ Project Setup** section, with all the necessary fixes for folder creation, file ownership, and config file persistence. This version ensures the container runs cleanly on first launch and preserves UI settings across rebuilds:

---

## ⚙️ Project Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/tsondo/a1111-docker.git
   cd a1111-docker
   ```

2. **Copy the environment template**
   ```bash
   cp .env.example .env
   ```

3. **Create required folders and config files**
   These folders will be mounted into the container and persist across runs:
   ```bash
   mkdir -p models/Stable-diffusion output wildcards extensions config embeddings logs cache
   touch config/config.json config/ui-config.json
   sudo chown -R $USER:$USER models output wildcards extensions config embeddings logs cache
   ```

   🧠 Tip: You can organize models by type inside `models/Stable-diffusion/` (e.g., `sd1.5/`, `sdxl/`).

4. **Edit `.env` to match your local paths**
   ```bash
   nano .env
   ```
   Example:
   ```env
   MODEL_DIR=/home/todd/a1111-docker/models
   OUTPUT_DIR=/home/todd/a1111-docker/output
   WILDCARD_DIR=/home/todd/a1111-docker/wildcards
   CONFIG_DIR=/home/todd/a1111-docker/config
   EMBEDDINGS_DIR=/home/todd/a1111-docker/embeddings
   LOGS_DIR=/home/todd/a1111-docker/logs
   CACHE_DIR=/home/todd/a1111-docker/cache
   ```

5. **Launch the container**
   ```bash
   docker compose up -d
   ```
---

## 🖼️ Usage

- Open [http://localhost:7860](http://localhost:7860)
- Place `.safetensors` or `.ckpt` files into:
  ```
  <MODEL_DIR>/Stable-diffusion/
  ```
- Generated images will appear in:
  ```
  <OUTPUT_DIR>/
  ```
- Wildcards go in:
  ```
  <WILDCARD_DIR>/
  ```
- Extensions live in:
  ```
  <EXTENSIONS_DIR>/
  ```
- Optional config files:
  ```
  <CONFIG_DIR>/config.json
  <CONFIG_DIR>/ui-config.json
  ```

🧠 Tip: Use subfolders like `sd1.5/`, `sdxl/`, and `lora/` to keep models organized by type.

---

## 📦 Pre‑installed Extensions

This image includes two baked-in extensions:

- **[ADetailer](https://github.com/Bing-su/adetailer)** – automatic face/feature detection and inpainting
- **[Dynamic Prompts](https://github.com/adieyal/sd-dynamic-prompts)** – wildcard-based prompt generation

All other extensions are mounted from your local `EXTENSIONS_DIR` and can be managed via the WebUI.

---

## 🧪 Recommended Extensions

These are tested and compatible with this build:

- **[ControlNet](https://github.com/Mikubill/sd-webui-controlnet)**
- **[Civitai Helper](https://github.com/butaixianran/Stable-Diffusion-Webui-Civitai-Helper)**
- **[Rembg](https://github.com/AUTOMATIC1111/stable-diffusion-webui-rembg)**
- **[Tag Autocomplete](https://github.com/DominikDoom/a1111-sd-webui-tagcomplete)**
- **[Prompt All‑in‑One](https://github.com/Physton/sd-webui-prompt-all-in-one)**
- **[Image Browser](https://github.com/yfszzx/stable-diffusion-webui-images-browser)**
- **[OpenPose Editor](https://github.com/fkunn1326/openpose-editor)**

---

## 🎯 Philosophy

This image is designed for:

- **Utility**: Solves real creative and workflow needs
- **Stability**: Uses widely adopted, actively maintained extensions
- **Reproducibility**: Keeps the base image clean and predictable

Your models, outputs, wildcards, and extensions are all mounted — nothing is baked into the container except the two core extensions. No snapshots required.

---

## 🛠️ Troubleshooting

- **Permission denied**: Ensure your folders exist and are writable
- **Models not detected**: Check they’re inside `Stable-diffusion/`
- **Slow I/O**: Avoid `/mnt/c/...` paths — use native WSL folders for speed

---

## 👥 Sharing

Anyone can use this setup by:

1. Installing Docker + WSL
2. Cloning the repo
3. Copying `.env.example` → `.env`
4. Editing paths
5. Running:
   ```bash
   docker compose up -d
   ```

Tested on Windows 11 with Ubuntu 22.04 WSL, across multiple workstations with NVIDIA 4080 and 5090 GPUs.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).  
You are free to use, modify, and distribute it with proper attribution.

---
