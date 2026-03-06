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

📘 **New to Docker or AUTOMATIC1111 in general?**  
Check out the [GETTING_STARTED.md](GETTING_STARTED.md) guide for a plain‑language introduction: what Docker is, what A1111 does, what’s persistent vs. ephemeral in this build, and how to add your first models.

---

## 🐧 Setup for Linux

### 1. Clone the repo

Open your terminal and run:

git clone https://github.com/tsondo/a1111-docker.git ~/a1111-docker
cd ~/a1111-docker

This gives you access to `setup.sh`, `docker-compose.yml`, and all required files.

### 2. Create your `.env` file

This project uses a `.env` file to define persistent folder paths for Docker volume mounts. A sample file is included in the repo. Run the following command to create your own `.env` file:

cp .env.sample .env

You can customize the paths inside `.env` if needed. The default values assume you're running everything from `~/a1111-docker`.

If you skip this step, `docker compose` will show warnings and fail to mount required folders correctly.


### 3. Install Docker and Docker Compose

Pick your distro below. All methods install Docker Engine with the Compose plugin (`docker compose`).

<details>
<summary><strong>Ubuntu / Debian</strong></summary>

```bash
# Add Docker's official GPG key and repo
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# For Debian, replace "ubuntu" with "debian" in the two URLs above

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine + Compose plugin
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

</details>

<details>
<summary><strong>Fedora</strong></summary>

```bash
# Add the Docker repo
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

# Install Docker Engine + Compose plugin
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable the Docker service
sudo systemctl enable --now docker
```

</details>

<details>
<summary><strong>Arch Linux</strong></summary>

```bash
# Install from the official Arch repos
sudo pacman -S docker docker-compose docker-buildx

# Start and enable the Docker service
sudo systemctl enable --now docker
```

</details>

After installing, add your user to the `docker` group so you can run commands without `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker   # applies the change in your current shell
```

Verify everything works:

```bash
docker --version
docker compose version
```

### 4. Run setup and launch

bash setup.sh
docker compose up

Access the WebUI at http://localhost:7860

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

git clone https://github.com/tsondo/a1111-docker.git ~/a1111-docker
cd ~/a1111-docker

### 4. Run setup. It will setup everything, build, then launch via docker compose up

bash setup.sh

Access the WebUI at http://localhost:7860 from your Windows browser.

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

## ⚠️ Why venv is *not* persisted

You may notice there is no `venv/` entry in the persistent folders above.  
That’s intentional: the Python virtual environment is built inside the image at build time.  
If you mount an empty host folder over `/workspace/stable-diffusion-webui/venv`, it hides the prebuilt environment and causes startup errors (`venv/bin/activate: No such file or directory`).  

Instead, this project persists the **pip cache** (`pip-cache/`), so package downloads are reused across runs.  
This keeps contributor setup simple and portable: extensions install their dependencies once, and subsequent installs are fast thanks to the cache, without risking an empty overlay of the venv.

---


## 📦 Preloading Models (Optional)

To pre-load model downloads before first launch:

mkdir -p ~/a1111-docker/models/Stable-diffusion
wget -O ~/a1111-docker/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors \
  https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors

---

## 🔁 Daily Usage: Bringing the Container Up and Down

💡 Tip: To ensure you always have the latest build, correct permissions, and all persistent folders in place, it’s best to start the WebUI using `setup.sh`.  

``` 
bash setup.sh
```

You can still run `docker compose up` directly, but the script makes sure updates and setup steps aren’t missed.

bash setup.sh will:

- Pull the latest repo updates
- Rebuild the container only if needed
- Verify all persistent folders and config files
- Launch the WebUI container

You can then access the interface at http://localhost:7860

---

### 🧪 Optional: Force Rebuild with `--no-cache`

If you're troubleshooting or testing Dockerfile changes, you can force a full rebuild:

bash setup.sh --no-cache

This bypasses Docker’s layer cache and rebuilds the container from scratch. Use this if:

- You modified the Dockerfile or build context
- You suspect stale layers or broken dependencies
- You want to test a clean build environment

---

### 🛑 To Stop the Container

docker compose down

This stops the running container but preserves all persistent data.

---
