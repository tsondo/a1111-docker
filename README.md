# 🚀 Automatic1111 in Docker (GPU‑accelerated)

This repo packages [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) into a reproducible Docker image with GPU passthrough.  
It’s designed so anyone can run it with **their own models and output folders** by editing a simple `.env` file.

---

## 📦 Prerequisites
- Docker Desktop with WSL2 backend (Windows) or Docker Engine (Linux)
- NVIDIA GPU + drivers + CUDA toolkit installed
- `docker compose` available in your shell

---

## ⚙️ Setup

1. Clone or download this repo:
   ```bash
   git clone https://github.com/<your-repo>/a1111-docker.git
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

## ⚡ Benchmarking (optional)

To test performance, try generating a batch of 10 images at 512×512.  
The console will show `it/s` (iterations per second) — a good baseline to compare across GPUs.

---

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
