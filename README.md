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

This project wraps [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) in a reproducible Docker setup with GPU support.  
It’s designed for persistent use: your models, outputs, configs, and extensions live outside the container and are mounted at runtime.

---

## 📦 Requirements

- **Windows 11**: Docker Desktop with WSL2 backend and Ubuntu 22.04 installed  
- **Linux**: Docker Engine with NVIDIA runtime

---

## 🖥️ Windows 11 Setup

1. **Install WSL2 with Ubuntu 22.04**
   ```powershell
   wsl --install -d Ubuntu-22.04
   ```

2. **Install Docker Desktop**  
   Download from [docker.com](https://www.docker.com/products/docker-desktop) and complete setup.

3. **Enable WSL Integration**  
   Docker Desktop → Settings → Resources → WSL Integration  
   Enable for your Ubuntu distro (`Ubuntu-22.04`)

4. **Open your WSL shell**  
   Launch Ubuntu from the Start Menu. You’ll land in `/home/<your-username>`

5. **Run Docker commands inside WSL**
   ```bash
   docker compose up -d
   ```

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
   mkdir -p models/Stable-diffusion outputs extensions/wildcards configs embeddings logs cache repositories
   touch configs/config.json configs/ui-config.json
   sudo chown -R $USER:$USER models outputs extensions configs embeddings logs cache repositories
   ```

4. **Edit `.env` to match your local paths**
   ```bash
   nano .env
   ```
   Example:
   ```env
   MODEL_DIR=/home/todd/a1111-docker/models
   OUTPUT_DIR=/home/todd/a1111-docker/outputs
   CONFIG_DIR=/home/todd/a1111-docker/configs
   WILDCARD_DIR=/home/todd/a1111-docker/extensions/wildcards
   EMBEDDINGS_DIR=/home/todd/a1111-docker/embeddings
   LOGS_DIR=/home/todd/a1111-docker/logs
   CACHE_DIR=/home/todd/a1111-docker/cache
   EXT_DIR=/home/todd/a1111-docker/extensions
   REPO_DIR=/home/todd/a1111-docker/repositories
   ```

5. **Launch the container**
   ```bash
   docker compose up -d --build
   ```

---

## 🖼️ Usage

- Open [http://localhost:7860](http://localhost:7860)
- Place `.safetensors` or `.ckpt` files into:
  ```
  models/Stable-diffusion/
  ```
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

## 📦 Pre‑installed Extensions

This image includes two baked-in extensions:

- **[ADetailer](https://github.com/Bing-su/adetailer)** – automatic face/feature detection and inpainting  
- **[Dynamic Prompts](https://github.com/adieyal/sd-dynamic-prompts)** – wildcard-based prompt generation

All other extensions are mounted from your local `extensions/` folder and can be managed via the WebUI.

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

Your models, outputs, configs, and extensions are all mounted — nothing is baked into the container except the two core extensions. No snapshots required.

---

## 🛠️ Troubleshooting

- **Permission denied**: Ensure your folders exist and are writable  
- **Models not detected**: Check they’re inside `Stable-diffusion/`  
- **Slow I/O**: Avoid `/mnt/c/...` paths — use native WSL folders for speed  
- **Accidental large push**: See “Clean Push Instructions” above

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
It packages and distributes configuration files for [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui), which is licensed under the AGPL-3.0.  
See [NOTICE](NOTICE) for details.
