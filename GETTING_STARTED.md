# Getting Started with a1111-docker

This guide is for anyone new to Docker or AUTOMATIC1111 (A1111). It explains the basics in plain language and points you back to the main [README.md](README.md) for deeper technical details.

---

## 🐳 What is Docker?

Docker is a way to package software into **containers**.  
Think of a container as a lightweight, portable box that includes everything the program needs (libraries, dependencies, configs).  
The benefit: the software runs the same way on any machine, without you having to manually install all the pieces.

---

## 🎨 What is AUTOMATIC1111 (A1111)?

AUTOMATIC1111 is a popular **web interface for Stable Diffusion**.  
It lets you generate, edit, and experiment with AI‑generated images through a browser.  
This build runs A1111 inside a Docker container, so you don’t have to worry about CUDA, Python, or dependency setup.

---

## 📦 Why this build?

This Docker setup separates what’s **ephemeral** (rebuilt each time) from what’s **persistent** (your data and settings):

- **Ephemeral (inside the container):**
  - Python environment
  - Installed packages
  - The container filesystem itself

- **Persistent (mounted from your host):**
  - `models/` → your Stable Diffusion checkpoints
  - `outputs/` → generated images
  - `configs/` → YAML configs
  - `extensions/` → installed extensions
  - `embeddings/`, `logs/`, `cache/`, `repositories/`
  - UI state files: `config.json`, `ui-config.json`, `styles.csv`

This means you can rebuild or update the container at any time without losing your models, outputs, or settings.

---

## 🚀 How to run

See the [README.md](README.md) for full setup instructions.  
In short: run the provided `setup.sh` script, then open your browser to:

http://localhost:7860

That’s the A1111 WebUI.

---

## 🧩 Adding models

This build expects either **Stable Diffusion 1.5** or **Stable Diffusion XL (SDXL)** models.

1. Download a model checkpoint (`.safetensors` or `.ckpt`) from a trusted source such as [Civitai](https://civitai.com).
2. Place it in one of these folders (on your host machine):

   models/Stable-diffusion/sd15/
   models/Stable-diffusion/sdxl/

3. Restart the container (`docker compose up`) and the model will appear in the WebUI dropdown.

---

## 🪟 Accessing folders from Windows

If you’re running Docker Desktop on Windows:

- The `a1111-docker` folder on your host is mounted into the container.
- That means you can drop models into `a1111-docker/models/Stable-diffusion/...` directly from Windows Explorer.
- Outputs will appear in `a1111-docker/outputs/` on your host.

---

## ✅ Summary

- Docker runs A1111 in a clean, reproducible environment.
- Your models, outputs, configs, and extensions are **persistent** on your host.
- Add SD1.5 or SDXL models under `models/Stable-diffusion/` to get started.
- Access the UI at http://localhost:7860.
- For full details, see the main [README.md](README.md).
