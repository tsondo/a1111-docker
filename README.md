![Build](https://img.shields.io/badge/build-passing-brightgreen)
![CUDA](https://img.shields.io/badge/CUDA-12.8-blue)
![GPU](https://img.shields.io/badge/GPU-NVIDIA%20enabled-yellowgreen)
![WSL2](https://img.shields.io/badge/WSL2-supported-green)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![Volumes](https://img.shields.io/badge/volumes-modular%20%26%20persistent-blueviolet)
![Extensions](https://img.shields.io/badge/extensions-user%20managed-orange)
![Snapshot](https://img.shields.io/badge/snapshots-not%20required-lightgrey)
![Tested](https://img.shields.io/badge/tested-4080%20%7C%205090-green)
![License](https://img.shields.io/github/license/tsondo/a1111-docker)

# 🚀 Automatic1111 in Docker (GPU‑accelerated)

This project wraps [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) in a reproducible Docker setup with GPU support.  
It’s designed for persistent use: your models, outputs, configs, and extensions live outside the container and are mounted at runtime.

---

## 📦 Requirements

This setup is designed for **Linux Docker Engine** or **Docker running inside WSL (Ubuntu 22.04)**.  
It does **not** support persistence when run with Docker for Windows directly.

- **Windows 11 + WSL2**: Install Ubuntu 22.04 in WSL, then install Docker Engine inside WSL. Run all commands from the Ubuntu shell, and use Linux‑style paths (`/home/<your-username>/...`).  
- **Linux**: Install Docker Engine with NVIDIA runtime.  
- **Docker for Windows (DfW)**: The container will run, but persistence is not supported. Models, outputs, configs, and extensions will be lost when the container is rebuilt or removed.  
  ⚠️ *Note*: Work is in progress on a Docker for Windows version that will support persistence.

---

## 🖥️ Windows 11 Setup (WSL2 + Docker Engine)

1. **Install WSL2 with Ubuntu 22.04**
   ```powershell
   wsl --install -d Ubuntu-22.04
   ```

2. **Install Docker Engine inside WSL**  
   Follow the official Docker instructions for Ubuntu 22.04:  
   [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

3. **Verify NVIDIA runtime**  
   Inside WSL, confirm your GPU is visible:
   ```bash
   nvidia-smi
   ```

4. **Confirm Docker is working**  
   Run:
   ```bash
   docker --version
   docker run hello-world
   ```
   If both succeed, Docker is ready.

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

3. **Create required folders and config files using setup.sh**
   Required folders will be mounted into the container and persist across runs:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

4. **Edit `.env` to match your local paths**  
   Replace `<your-username>` with your actual Linux username.
   ```bash
   nano .env
   ```
   Example:
   ```env
   MODEL_DIR=/home/<your-username>/a1111-docker/models
   OUTPUT_DIR=/home/<your-username>/a1111-docker/outputs
   CONFIG_DIR=/home/<your-username>/a1111-docker/configs
   WILDCARD_DIR=/home/<your-username>/a1111-docker/extensions/wildcards
   EMBEDDINGS_DIR=/home/<your-username>/a1111-docker/embeddings
   LOGS_DIR=/home/<your-username>/a1111-docker/logs
   CACHE_DIR=/home/<your-username>/a1111-docker/cache
   EXT_DIR=/home/<your-username>/a1111-docker/extensions
   REPO_DIR=/home/<your-username>/a1111-docker/repositories
   ```

5. **Launch the container**
   ```bash
   docker compose up -d --build
   ```

---

## 🖼️ Usage

- Open the WebUI in your browser:  
  [http://localhost:7860](http://localhost:7860)  

  💡 You can also connect from **any device on your local network** by replacing `localhost` with your machine’s LAN IP address, e.g.:  
  ```
  http://192.168.1.42:7860
  ```

- Place `.safetensors` or `.ckpt` files into:
  ```
  models/Stable-diffusion/
  ```
  Then **refresh the model list inside the WebUI** to see them appear.

- Generated images will appear in:
  ```
  outputs/
  ```

- Wildcards go in:
  ```
  extensions/wildcards/
  ```

- Extensions live in:
  ```
  extensions/
  ```

- Optional config files:
  ```
  configs/config.json
  configs/ui-config.json
  ```

🧠 Tip: Use subfolders like `sd1.5/`, `sdxl/`, and `lora/` to organize models by type.

---

## 🧹 Clean Push Instructions

To avoid pushing large model files or outputs:

1. Confirm `.gitignore` excludes all persistent folders  
2. Remove any tracked assets:
   ```bash
   git rm --cached -r models outputs extensions repositories configs
   git commit -m "Clean tracked files now ignored"
   git push origin HEAD --force
   ```

---

## 📦 Extensions

This image does **not** include any baked‑in extensions.  
All extensions are managed through the WebUI or by placing them into your persistent `extensions/` folder.  

Because the `extensions/` directory is mounted as a volume, any extensions you install will persist across container rebuilds and updates.

---

## 🧪 Recommended Extensions

These extensions are tested and compatible with this build.  
They can be added through the **Extensions** tab within the A1111 WebUI:

- **ADetailer** – automatic face/feature detection and inpainting  
- **Dynamic Prompts** – wildcard-based prompt generation for varied outputs  
- **ControlNet** – adds fine-grained control over image generation using pose, depth, edges, or other conditioning inputs  
- **Civitai Helper** – streamlines downloading, updating, and managing models directly from Civitai  
- **Rembg** – removes image backgrounds automatically for clean subject isolation  
- **Tag Autocomplete** – suggests and autocompletes tags while typing prompts, reducing errors and speeding workflow  
- **Prompt All‑in‑One** – provides a unified interface for managing prompt history, presets, and templates  
- **Image Browser** – lets you browse, search, and manage generated images directly inside the WebUI  
- **OpenPose Editor** – interactive editor for creating and adjusting human poses to guide ControlNet generations

---

## 🎯 Philosophy

This image is designed for:

- **Utility**: Solves real creative and workflow needs  
- **Stability**: Uses widely adopted, actively maintained extensions  
- **Reproducibility**: Keeps the base image clean and predictable

Your models, outputs, configs, and extensions are all mounted — nothing is baked into the container. No snapshots required.

---

## 🛠️ Troubleshooting

- **Permission denied**: Ensure your folders exist and are writable  
- **Models not detected**: Check they’re inside `Stable-diffusion/`  
- **Slow I/O**: Avoid `/mnt/c/...` paths — use native WSL folders for speed  
- **Accidental large push**: See “Clean Push Instructions” above  
- **Using Docker for Windows?**  
  The container will run, but persistence is not supported. Work is in progress on a DfW version that will support persistence.

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

