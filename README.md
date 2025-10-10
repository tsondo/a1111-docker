![Build](https://img.shields.io/badge/build-passing-brightgreen)
![CUDA](https://img.shields.io/badge/CUDA-12.8-blue)
![Torch](https://img.shields.io/badge/Torch-2.2.2-informational)
![xFormers](https://img.shields.io/badge/xFormers-enabled-success)
![Extension](https://img.shields.io/badge/ADetailer-persistent-success)
![License](https://img.shields.io/github/license/tsondo/a1111-docker)

# 🧠 a1111-docker

A reproducible, persistent Docker setup for running [AUTOMATIC1111's Stable Diffusion WebUI](https://github.com/AUTOMATIC1111/stable-diffusion-webui) with GPU acceleration, extension support, and clean config management.

---

## 🚀 Quick Start

```bash
bash setup.sh
cd ~/a1111-docker
docker compose up
```

This will:

- Clone the repo (or update it)
- Create persistent folders for configs, models, outputs, and extensions
- Prepopulate empty config files if missing
- Launch the WebUI on [localhost:7860](http://localhost:7860)

---

## 🧱 Persistent Folders

These folders are mounted into the container and survive restarts:

| Host Folder       | Container Path                                      | Purpose                          |
|-------------------|-----------------------------------------------------|----------------------------------|
| `configs/`        | `/workspace/stable-diffusion-webui/configs`         | UI and runtime config files      |
| `models/`         | `/workspace/stable-diffusion-webui/models`          | Base models and checkpoints      |
| `outputs/`        | `/workspace/stable-diffusion-webui/outputs`         | Generated images                 |
| `extensions/`     | `/workspace/stable-diffusion-webui/extensions`      | Installed extensions             |
| `embeddings/`     | `/workspace/stable-diffusion-webui/embeddings`      | Textual inversion embeddings     |
| `logs/`           | `/workspace/stable-diffusion-webui/logs`            | Runtime logs                     |
| `cache/`          | `/workspace/stable-diffusion-webui/cache`           | Model and UI cache               |
| `repositories/`   | `/workspace/stable-diffusion-webui/repositories`    | Extension repos and wildcards    |

---

## 🖥️ Platform Setup

### 🪟 Docker for Windows (with integrated WSL)

**Requirements:**

- Docker Desktop installed with WSL integration enabled
- WSL2 backend (Ubuntu recommended)

**Steps:**

1. Open your WSL terminal (e.g., Ubuntu via Windows Terminal)
2. Run:
   ```bash
   bash setup.sh
   cd ~/a1111-docker
   docker compose up
   ```
3. Access the WebUI at [localhost:7860](http://localhost:7860) from your Windows browser

**Notes:**

- Run all commands inside WSL — not PowerShell or CMD
- Persistent folders live inside your WSL home directory

---

### 🐧 Docker for Linux (native or WSL)

**Requirements:**

- Docker and Docker Compose installed
- NVIDIA GPU with drivers and `nvidia-container-toolkit` installed

**Steps:**

1. Open your terminal
2. Run:
   ```bash
   bash setup.sh
   cd ~/a1111-docker
   docker compose up
   ```
3. Access the WebUI at [localhost:7860](http://localhost:7860)

**Notes:**

- GPU acceleration (xFormers, CUDA) is enabled by default
- No special flags or environment variables required

---

## 🧩 Extension Persistence

Any extensions installed via the WebUI (e.g., ADetailer) will persist across restarts. They are stored in the `extensions/` folder and mounted into the container.

---

## 📦 Preloading Models (Optional)

To skip model downloads on first launch:

```bash
mkdir -p ~/a1111-docker/models/Stable-diffusion
wget -O ~/a1111-docker/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors \
  https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
```

---

## 🧼 Teardown and Rebuild

To stop and restart cleanly:

```bash
docker compose down
docker compose up
```

To rebuild the container:

```bash
docker compose up --build
```

---
