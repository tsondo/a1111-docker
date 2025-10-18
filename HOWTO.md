# 🐧 Installing Docker in WSL (Ubuntu 22.04)

Follow these steps to set up Docker inside WSL. Once complete, your containers will auto‑start as described in the main README.

---

## 1. Install WSL with Ubuntu 22.04

Open **PowerShell as Administrator** and run:

    wsl --install -d Ubuntu-22.04

If you already have WSL installed, make sure Ubuntu‑22.04 is set to version 2:

    wsl --set-version Ubuntu-22.04 2

Then launch **Ubuntu 22.04** from the Start menu and create your Linux username and password.  
👉 This password is important — you’ll use it whenever `sudo` asks for authentication.

---

## 2. Install Docker Inside Ubuntu

In your Ubuntu terminal:

    # Update packages
    sudo apt update && sudo apt upgrade -y

    # Install dependencies
    sudo apt install ca-certificates curl gnupg lsb-release -y

    # Add Docker’s official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine and Compose plugin
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

---

## 3. Add Your User to the Docker Group

By default, Docker requires `sudo`. To run it as your normal user:

    sudo usermod -aG docker $USER
    newgrp docker

Now you can run `docker ps` without `sudo`.

---

## 4. Verify Installation

    docker --version
    docker compose version

Both should print version numbers.

---

## 5. Notes About Password Prompts

- If the container setup or Dockerfile runs commands with `sudo`, you may be asked for your **Ubuntu user password**.
- This is the same password you created the very first time you launched Ubuntu in WSL.

---

## 6. Enable NVIDIA GPU Support in WSL

To use GPU acceleration inside Docker containers, you need the NVIDIA runtime and drivers set up in WSL:

1. **Install the NVIDIA GPU driver for WSL on Windows**  
   Download and install the latest [NVIDIA WSL driver](https://developer.nvidia.com/cuda/wsl) from NVIDIA’s site. This enables GPU passthrough into WSL.

2. **Install the NVIDIA Container Toolkit inside Ubuntu**  
   In your WSL terminal:

       distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
       curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
       curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list \
         | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

       sudo apt update
       sudo apt install -y nvidia-docker2

3. **Update to the latest NVIDIA Container Toolkit (important for CUDA 12.8+)**  
   Recent NVIDIA drivers (555.xx and newer) require an updated toolkit to expose new libraries (`libnvdxgdmal.so.1`) into containers.  
   Run:

       sudo apt install -y nvidia-container-toolkit

   This ensures CUDA initialization works correctly inside WSL.

4. **Restart the Docker daemon**

       sudo systemctl restart docker

5. **Test GPU access**  
   Run:

       docker run --rm --gpus all nvidia/cuda:12.3.2-base-ubuntu22.04 nvidia-smi

   You should see your GPU listed.

---

✅ That’s it — Docker is ready. Head back to the main README for instructions on cloning the repo and running the container.
