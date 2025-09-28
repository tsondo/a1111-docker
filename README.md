![Build](https://img.shields.io/badge/build-passing-brightgreen)
![CUDA](https://img.shields.io/badge/CUDA-12.8-blue)
![Extension](https://img.shields.io/badge/ADetailer-enabled-success)
![License](https://img.shields.io/github/license/tsondo/a1111-docker)

# 🚀 Automatic1111 in Docker (GPU‑accelerated)

This repo wraps [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) in a reproducible Docker setup with GPU support.  
Just edit the `.env` file to use your own models, outputs, and wildcards.

---

## 📦 Requirements

- **Windows 11**: Docker Desktop with WSL2 backend, plus integrated local install of WSL  
- **Linux**: Docker Engine with NVIDIA runtime

---

## 🖥️ Windows 11 Setup

To run this on Windows 11, follow these steps:

1. **Install WSL2**  
   Open PowerShell as Administrator and run:  
   ```powershell
   wsl --install -d Ubuntu-22.04
   ```  
   This installs Ubuntu 22.04 from the Microsoft Store. Many other distros will work, but I've tested this one.

2. **Install Docker Desktop**  
   Download from [docker.com](https://www.docker.com/products/docker-desktop) and complete setup.

3. **Enable WSL Integration**  
   In Docker Desktop → Settings → Resources → WSL Integration  
   Enable it for your Ubuntu distro (e.g., `Ubuntu-22.04`)

4. **Open your WSL shell**  
   Press `Windows + S`, type `Ubuntu`, and launch the app.  
   You’ll land in your Linux home directory (e.g., `/home/<whatever you chose for your username>`)

5. **Run Docker commands inside WSL**  
   Always use the WSL shell to run commands like:  
   ```bash
   docker compose up -d
   ```

6. **(Optional) Enable GPU support**  
   If you have an NVIDIA GPU and want CUDA available for other projects, install the [CUDA toolkit for WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html) and verify with:  
   ```bash
   nvidia-smi
   ```
   For this project is it not strictly necessary because CUDA will be pulled into the docker image anyway.
---

## ⚙️ A1111 for Docker Setup

1. Clone or download this repo:
   ```bash
   git clone https://github.com/tsondo/a1111-docker.git
   cd a1111-docker
   ```

2. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

3. Create and edit `.env` to point to your own folders (this is optional: it allows you to keep your models, output, and prompt wildcards persistent)
   ```env
   MODEL_DIR=/mnt/d/Projects/python/automatic1111/stable-diffusion-webui/models
   OUTPUT_DIR=/mnt/d/Projects/python/automatic1111/stable-diffusion-webui/output
   WILDCARD_DIR=/mnt/d/Projects/python/automatic1111/stable-diffusion-webui/extensions/sd-dynamic-prompts/wildcards
   ```
Note: you can mount windows folders for these, but I recommend you create a folder inside your WSL because it's much faster. E.g. MODEL_DIR=/home/yourusername/models

4. Run the container:
   ```bash
   docker compose up
   ```

---

## 🖼️ Usage

- Open [http://localhost:7860](http://localhost:7860) in your browser.
- Place `.safetensors` or `.ckpt` files into:
  ```
  <MODEL_DIR>/Stable-diffusion/
Note: I recomment separate folders by model type. For example, create an sdxl folder, and an sd1.5 folder. Do this for both Stable-diffusion and your lora folder so you can make sure they match when you create prompts. If you don't know what that means yet, refer back here after you start using different base models and loras.
  
  ```
- Generated images will appear in:
  ```
  <OUTPUT_DIR>/
  ```
SUbfolders will be created based on what type of output, text-image, etc, and by date.
---

## 📦 Pre‑installed Extensions

This image comes two popular AUTOMATIC1111 extensions already intalled:

- **[ADetailer](https://github.com/Bing-su/adetailer)** – automatic face/feature detection and targeted inpainting.  
- **[Dynamic Prompts](https://github.com/adieyal/sd-dynamic-prompts)** – template‑style prompts with wildcards, randomization, and combinatorics.  


Recommended extentions, tested with this build. Add from the extensions tab (it's quick):

- **[ControlNet](https://github.com/Mikubill/sd-webui-controlnet)** – adds pose/depth/edge guidance networks for more controllable generations.  

Still in testing:
- **[Civitai Helper](https://github.com/butaixianran/Stable-Diffusion-Webui-Civitai-Helper)** – integrates with Civitai for model previews, metadata, and management.  
- **[Rembg](https://github.com/AUTOMATIC1111/stable-diffusion-webui-rembg)** – background removal using ONNX models (U²‑Net, ISNet, etc.).  
- **[Tag Autocomplete](https://github.com/DominikDoom/a1111-sd-webui-tagcomplete)** – adds autocomplete for prompt tags.  
- **[Prompt All‑in‑One](https://github.com/Physton/sd-webui-prompt-all-in-one)** – manage prompt presets, history, and variations.  
- **[Image Browser](https://github.com/yfszzx/stable-diffusion-webui-images-browser)** – gallery tab to browse, search, and filter generated images.  
- **[OpenPose Editor](https://github.com/fkunn1326/openpose-editor)** – GUI tool to draw/edit poses for ControlNet.

All extensions can be added, updated or removed directly from the WebUI’s Extensions tab.

## 🎯 Why These Extensions?

This image isn’t meant to be a kitchen sink — it’s a curated set of extensions chosen for their balance of **utility, stability, and reproducibility**.  

- **Utility:** Each extension solves a common creative or workflow need (detail refinement, prompt management, controllable generation, background removal, etc.).  
- **Stability:** Only widely used, actively maintained extensions are included, minimizing the risk of breakage or obscure dependencies.  
- **Reproducibility:** By baking them into the image, collaborators and future users get the same baseline environment, reducing “it works on my machine” issues.  

The goal is to provide a **trusted starting point**: powerful enough for everyday use, lean enough to stay maintainable, and transparent enough that anyone can see exactly what’s inside.


## 🛠️ Troubleshooting

- **Permission denied**: Ensure your `MODEL_DIR` and `OUTPUT_DIR` exist and are writable by your Windows user.  
- **Models not detected**: Check that they’re inside the `Stable-diffusion/` subfolder.  
- **Slow I/O**: Mounting from `/mnt/d/...` is slower than WSL’s native ext4. For max speed, copy models into your WSL home and update `.env`.

---

## 👥 Sharing

Anyone can use this setup by:
1. Cloning the repo
2. Copying `.env.example` → `.env`
3. Editing paths
4. Running `docker compose up`
```
## License

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute it with proper attribution.

