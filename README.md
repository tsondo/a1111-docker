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
