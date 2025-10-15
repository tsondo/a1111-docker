![Build](https://img.shields.io/badge/build-passing-brightgreen)
![CUDA](https://img.shields.io/badge/CUDA-12.8-blue)
![Torch](https://img.shields.io/badge/Torch-2.2.2-informational)
![xFormers](https://img.shields.io/badge/xFormers-enabled-success)
![Extension](https://img.shields.io/badge/ADetailer-persistent-success)
![License](https://img.shields.io/github/license/tsondo/a1111-docker)

# 🧠 a1111-docker

A reproducible, persistent Docker setup for running [AUTOMATIC1111's Stable Diffusion WebUI](https://github.com/AUTOMATIC1111/stable-diffusion-webui) with GPU acceleration, extension support, and clean config management.

---

📖 **New to WSL/Docker on Windows?**  
See the [HOWTO guide](HOWTO.md) for step‑by‑step instructions on installing Docker inside WSL (Ubuntu 22.04) before using this project.

---

## 🐧 Setup for Linux (Ubuntu, Debian, Arch, etc. Assumes Docker with Compose is already installed)

### 1. Clone the repo

Open your terminal and run:

```bash
git clone https://github.com/tsondo/a1111-docker.git ~/a1111-docker
cd ~/a1111-docker
```

This gives you access to `setup.sh`, `docker-compose.yml`, and all required files.

### 2. Install Docker and Docker Compose

Follow official instructions:  
https://docs.docker.com/engine/install/

Then install Docker Compose plugin:

```bash
sudo apt install docker-compose-plugin
```

Add your user to the Docker group (optional):

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### 3. Run setup and launch

```bash
bash setup.sh
docker compose up
```

Access the WebUI at [http://localhost:7860](http://localhost:7860)

---

## 🪟 Setup for Windows (Docker Desktop + WSL2)

### 1. Install Docker Desktop

Download and install from:  
https://www.docker.com/products/docker-desktop/

Enable **WSL2 integration** during setup. You’ll need:

- Windows 10/11 with WSL2 enabled
- A Linux distro installed (Ubuntu recommended)

### 2. Open your WSL terminal

Use Windows Terminal or your preferred terminal app to open Ubuntu (or other WSL distro).

### 3. Clone the repo inside WSL

```bash
git clone https://github.com/tsondo/a1111-docker.git ~/a1111-docker
cd ~/a1111-docker
```

### 4. Run setup. It will setup everything, build, then launch via docker compose up

```bash
bash setup.sh
```

Access the WebUI at [http://localhost:7860](http://localhost:7860) from your Windows browser.

**Important:**  
Run all commands inside WSL — not PowerShell or CMD.  
Your persistent folders live inside your WSL home directory.

---

## 🚀 What setup.sh does

- Creates persistent folders for configs, models, outputs, extensions, etc.
- Prepopulates empty config files if missing
- Ensures correct ownership and permissions
- Prepares everything for `docker compose up`

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

## 🧩 Extension Persistence

Any extensions installed via the WebUI (e.g., ADetailer) will persist across restarts. They are stored in the `extensions/` folder and mounted into the container.

---

## 📦 Preloading Models (Optional)

To pre-load model downloads before first launch:

```bash
mkdir -p ~/a1111-docker/models/Stable-diffusion
wget -O ~/a1111-docker/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors \
  https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
```

---
## 🔁 Daily Usage: Bringing the Container Up and Down

To start the WebUI each day, **always run `setup.sh`** — not just `docker compose up`. This ensures all folders, configs, and updates are in place before launch.

```bash
bash setup.sh
```

This will:

- Pull the latest repo updates
- Rebuild the container only if needed
- Verify all persistent folders and config files
- Launch the WebUI container

Access the interface at [http://localhost:7860](http://localhost:7860)

---

### 🧪 Optional: Force Rebuild with `--no-cache`

If you're troubleshooting or testing Dockerfile changes, you can force a full rebuild:

```bash
bash setup.sh --no-cache
```

This bypasses Docker’s layer cache and rebuilds the container from scratch. Use this if:

- You modified the Dockerfile or build context
- You suspect stale layers or broken dependencies
- You want to test a clean build environment

---

### 🛑 To Stop the Container

```bash
docker compose down
```

This stops the running container but preserves all persistent data.


---
