
![Build](https://img.shields.io/badge/build-passing-brightgreen)
![CUDA](https://img.shields.io/badge/CUDA-12.8-blue)
![Extension](https://img.shields.io/badge/ADetailer-enabled-success)

# 🚀 Automatic1111 in Docker (GPU‑accelerated)

This repo packages [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) into a reproducible Docker image with GPU passthrough.  
It’s designed so anyone can run it with **their own models and output folders** by editing a simple `.env` file.

---

## 📦 Prerequisites
- Docker Desktop with WSL2 backend (Windows) or Docker Engine (Linux). Enable integration with additional distros 20 current compatible linux distro chosen.
- NVIDIA GPU + drivers + CUDA toolkit installed
- `docker compose` available in your shell

---

## ⚙️ Setup

1. Clone or download this repo:
   ```bash
   git clone https://github.com/tsondo/a1111-docker.git
   cd a1111-docker
   ```

2. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` to point to your own folders:
   ```env
   MODEL_DIR=/mnt/d/Projects/python/automatic1111/stable-diffusion-webui/models
   OUTPUT_DIR=/mnt/d/Projects/python/automatic1111/stable-diffusion-webui/output
   ```

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
  ```
- Generated images will appear in:
  ```
  <OUTPUT_DIR>/txt2img-images/
  ```

---

## 📦 Pre‑installed Extensions

This image comes with several popular AUTOMATIC1111 extensions already included:

- **[ADetailer](https://github.com/Bing-su/adetailer)** – automatic face/feature detection and targeted inpainting.  
- **[Dynamic Prompts](https://github.com/adieyal/sd-dynamic-prompts)** – template‑style prompts with wildcards, randomization, and combinatorics.  


Future additions planned (still testing):

- **[ControlNet](https://github.com/Mikubill/sd-webui-controlnet)** – adds pose/depth/edge guidance networks for more controllable generations.  
- **[Civitai Helper](https://github.com/butaixianran/Stable-Diffusion-Webui-Civitai-Helper)** – integrates with Civitai for model previews, metadata, and management.  
- **[Rembg](https://github.com/AUTOMATIC1111/stable-diffusion-webui-rembg)** – background removal using ONNX models (U²‑Net, ISNet, etc.).  
- **[Tag Autocomplete](https://github.com/DominikDoom/a1111-sd-webui-tagcomplete)** – adds autocomplete for prompt tags.  
- **[Prompt All‑in‑One](https://github.com/Physton/sd-webui-prompt-all-in-one)** – manage prompt presets, history, and variations.  
- **[Image Browser](https://github.com/yfszzx/stable-diffusion-webui-images-browser)** – gallery tab to browse, search, and filter generated images.  
- **[OpenPose Editor](https://github.com/fkunn1326/openpose-editor)** – GUI tool to draw/edit poses for ControlNet.

All extensions can be updated or toggled directly from the WebUI’s Extensions tab.

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

This project packages [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui),  
which is licensed under the [GNU Affero General Public License v3 (AGPL‑3.0)](https://www.gnu.org/licenses/agpl-3.0.html).

All modifications in this repository are also provided under the AGPL‑3.0.
