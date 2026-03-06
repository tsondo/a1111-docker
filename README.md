![Build](https://img.shields.io/badge/build-passing-brightgreen)
![CUDA](https://img.shields.io/badge/CUDA-12.8-blue)
![Torch](https://img.shields.io/badge/Torch-2.2.2-informational)
![xFormers](https://img.shields.io/badge/xFormers-enabled-success)
![Extension](https://img.shields.io/badge/ADetailer-persistent-success)
![License](https://img.shields.io/github/license/tsondo/a1111-docker)

# 🧠 a1111-docker

A reproducible, persistent Docker setup for running [AUTOMATIC1111's Stable Diffusion WebUI](https://github.com/AUTOMATIC1111/stable-diffusion-webui) with GPU acceleration, extension support, and clean config management.

---

📖 **Need to install Docker or the NVIDIA Container Toolkit?**  
See the [HOWTO guide](HOWTO.md) for step-by-step instructions for Ubuntu/Debian, Fedora, Arch, and WSL.

📘 **New to Docker or AUTOMATIC1111 in general?**  
Check out the [GETTING_STARTED.md](GETTING_STARTED.md) guide for a plain-language introduction: what Docker is, what A1111 does, what's persistent vs. ephemeral in this build, and how to add your first models.

---

## 🐧 Setup for Linux

**Prerequisites:** Docker Engine, Docker Compose plugin, and the NVIDIA Container Toolkit must be installed.
If you need help setting these up, see the [HOWTO guide](HOWTO.md).

### 1. Clone the repo

```bash
git clone https://github.com/tsondo/a1111-docker.git ~/a1111-docker
cd ~/a1111-docker
```

### 2. Create your `.env` file

```bash
cp .env.sample .env
```

You can customize the paths inside `.env` if needed. The defaults assume you're running from `~/a1111-docker`.

### 3. Run setup and launch

```bash
bash setup.sh
```

Access the WebUI at http://localhost:7860

---

## 🪟 Setup for Windows (Docker Desktop + WSL2)

**Prerequisites:** Docker Desktop with WSL2 integration and the NVIDIA Container Toolkit.
See the [HOWTO guide](HOWTO.md) for full setup steps.

Once Docker is working inside your WSL terminal:

```bash
git clone https://github.com/tsondo/a1111-docker.git ~/a1111-docker
cd ~/a1111-docker
cp .env.sample .env
bash setup.sh
```

Access the WebUI at http://localhost:7860 from your Windows browser.

**Important:** Run all commands inside WSL -- not PowerShell or CMD.

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

## ⚠️ Why venv is *not* persisted

You may notice there is no `venv/` entry in the persistent folders above.  
That's intentional: the Python virtual environment is built inside the image at build time.  
If you mount an empty host folder over `/workspace/stable-diffusion-webui/venv`, it hides the prebuilt environment and causes startup errors (`venv/bin/activate: No such file or directory`).  

Instead, this project persists the **pip cache** (`pip-cache/`), so package downloads are reused across runs.  
This keeps contributor setup simple and portable: extensions install their dependencies once, and subsequent installs are fast thanks to the cache, without risking an empty overlay of the venv.

---


## 📦 Preloading Models (Optional)

To pre-load model downloads before first launch:

```bash
mkdir -p ~/a1111-docker/models/Stable-diffusion
wget -O ~/a1111-docker/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
```

---

## 🔁 Daily Usage: Bringing the Container Up and Down

💡 Tip: To ensure you always have the latest build, correct permissions, and all persistent folders in place, it's best to start the WebUI using `setup.sh`.  

``` 
bash setup.sh
```

You can still run `docker compose up` directly, but the script makes sure updates and setup steps aren't missed.

bash setup.sh will:

- Pull the latest repo updates
- Rebuild the container only if needed
- Verify all persistent folders and config files
- Launch the WebUI container

You can then access the interface at http://localhost:7860

---

### 🧪 Optional: Force Rebuild with `--no-cache`

If you're troubleshooting or testing Dockerfile changes, you can force a full rebuild:

```bash
bash setup.sh --no-cache
```

This bypasses Docker's layer cache and rebuilds the container from scratch. Use this if:

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
