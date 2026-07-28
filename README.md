![Build](https://github.com/tsondo/a1111-docker/actions/workflows/publish.yml/badge.svg)
![CUDA](https://img.shields.io/badge/CUDA-12.8-blue)
![Torch](https://img.shields.io/badge/Torch-cu128-informational)
![xFormers](https://img.shields.io/badge/xFormers-enabled-success)
![A1111](https://img.shields.io/badge/A1111-v1.10.1-informational)
![License](https://img.shields.io/github/license/tsondo/a1111-docker)

# 🧠 a1111-docker

A reproducible, persistent Docker setup for running [AUTOMATIC1111's Stable Diffusion WebUI](https://github.com/AUTOMATIC1111/stable-diffusion-webui) with GPU acceleration, extension support, and clean config management.

Everything the WebUI needs — Python environment, requirements, and the sub-repositories A1111 depends on — is baked into the image at build time, pinned to a known-good release. First launch needs no network access and no surprise downloads.

---

📖 **Need to install Docker or the NVIDIA Container Toolkit?**  
See the [HOWTO guide](HOWTO.md) for step-by-step instructions for Ubuntu/Debian, Fedora, Arch, and WSL.

📘 **New to Docker or AUTOMATIC1111 in general?**  
Check out the [GETTING_STARTED.md](GETTING_STARTED.md) guide for a plain-language introduction: what Docker is, what A1111 does, what's persistent vs. ephemeral in this build, and how to add your first models.

---

## 🐧 Setup for Linux

**Prerequisites:** Docker Engine, Docker Compose plugin, and the NVIDIA Container Toolkit must be installed.
If you need help setting these up, see the [HOWTO guide](HOWTO.md).

```bash
git clone https://github.com/tsondo/a1111-docker.git ~/a1111-docker
cd ~/a1111-docker
bash setup.sh
```

That's it. `setup.sh` creates the persistent folders and config files, builds the image, and starts the container. Access the WebUI at http://localhost:7860

A `.env` file is optional — the defaults work out of the box. Copy `.env.sample` to `.env` if you want to customize where models, outputs, etc. are stored.

---

## 🪟 Setup for Windows (Docker Desktop + WSL2)

**Prerequisites:** Docker Desktop with WSL2 integration and the NVIDIA Container Toolkit.
See the [HOWTO guide](HOWTO.md) for full setup steps.

Once Docker is working inside your WSL terminal:

```bash
git clone https://github.com/tsondo/a1111-docker.git ~/a1111-docker
cd ~/a1111-docker
bash setup.sh
```

Access the WebUI at http://localhost:7860 from your Windows browser.

**Important:** Run all commands inside WSL -- not PowerShell or CMD. Keep the folder inside the Linux filesystem (`~/a1111-docker`), not under `/mnt/c/`, for much better performance.

---

## 📦 Prebuilt image (skip the build)

Building locally downloads several GB of CUDA wheels and takes a while. If a prebuilt image has been published to GHCR you can pull it instead:

```bash
bash setup.sh --pull
```

If no published image is available, the script falls back to building locally.

---

## 🚀 What setup.sh does

- Creates persistent folders for models, outputs, extensions, etc.
- Prepopulates empty config files if missing
- Records your user/group ID so files created by the container are owned by you
- Migrates settings from older versions of this project
- Builds (or pulls, with `--pull`) the image and starts the container

Flags: `--pull` (use prebuilt image), `--no-cache` (full rebuild), `-d`/`--detach` (run in background), `-h` (help).

---

## 🧱 Persistent Folders

These folders are mounted into the container and survive restarts and rebuilds:

| Host Folder       | Container Path                                      | Purpose                          |
|-------------------|-----------------------------------------------------|----------------------------------|
| `models/`         | `/workspace/stable-diffusion-webui/models`          | Base models and checkpoints      |
| `outputs/`        | `/workspace/stable-diffusion-webui/outputs`         | Generated images                 |
| `extensions/`     | `/workspace/stable-diffusion-webui/extensions`      | Installed extensions             |
| `embeddings/`     | `/workspace/stable-diffusion-webui/embeddings`      | Textual inversion embeddings     |
| `logs/`           | `/workspace/stable-diffusion-webui/logs`            | Runtime logs                     |
| `cache/`          | `/workspace/stable-diffusion-webui/cache`           | HuggingFace and UI cache         |
| `pip-cache/`      | `/workspace/stable-diffusion-webui/pip-cache`       | Pip download cache               |

UI state is persisted as individual files in the repo root: `config.json`, `ui-config.json`, and `styles.csv`.

Everything else — the Python environment, A1111 itself, and its sub-repositories — lives inside the image. Rebuilding or updating the image never touches your persistent data.

---

## 🧩 Extension Persistence

Any extensions installed via the WebUI (e.g., ADetailer) will persist across restarts. They are stored in the `extensions/` folder and mounted into the container. Their Python dependencies install into the container on first start after a rebuild; the mounted `pip-cache/` keeps that fast.

---

## 📌 Version pinning

The image builds AUTOMATIC1111 at a pinned release (`v1.10.1`) rather than whatever `master` happens to be that day, so builds are reproducible. To try a different release:

```bash
docker compose build --build-arg A1111_VERSION=v1.10.0
```

or edit `A1111_VERSION` in the Dockerfile.

> **Note:** Stability-AI deleted their original `stablediffusion` repository from GitHub, which broke older versions of this project (and stock A1111 installs). The image now clones a fork that preserves the exact commit A1111 expects.

---

## 📦 Preloading Models (Optional)

To pre-load model downloads before first launch:

```bash
mkdir -p ~/a1111-docker/models/Stable-diffusion
wget -O ~/a1111-docker/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
```

---

## 🔁 Daily Usage

Start:

```bash
docker compose up -d
```

Stop:

```bash
docker compose down
```

Watch logs:

```bash
docker compose logs -f
```

Running `bash setup.sh` again is always safe — it re-verifies folders and configs before starting.

---

## ⬆️ Updating

```bash
cd ~/a1111-docker
git pull
bash setup.sh
```

Docker only rebuilds the layers that changed. Your models, outputs, and settings are untouched.

If you're troubleshooting a broken build, force a clean one:

```bash
bash setup.sh --no-cache
```
