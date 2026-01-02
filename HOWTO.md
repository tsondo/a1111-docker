# 🐧 Installing Docker in WSL (Ubuntu 22.04) or Native Ubuntu/Pop!_OS 22.04

This guide walks you through installing Docker and Docker Compose on Ubuntu 22.04, whether you're running it inside WSL, Pop!_OS, or a VM. The steps are identical except where noted.

## 1. Install WSL with Ubuntu 22.04 (WSL‑only)

If you're using WSL, open PowerShell as Administrator and run:

wsl --install -d Ubuntu-22.04

If WSL is already installed, ensure Ubuntu‑22.04 is set to version 2:

wsl --set-version Ubuntu-22.04 2

Then launch Ubuntu 22.04 from the Start menu and create your Linux username and password.

If you're using Pop!_OS or Ubuntu in a VM, skip to the next section.

## 2. Install Docker Inside Ubuntu / Pop!_OS 22.04

Open your terminal and run:

sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## 3. Add Your User to the Docker Group

To run Docker without sudo:

sudo usermod -aG docker $USER

Important: You must log out and back in, or reboot, for this change to take effect. Without this, Docker will return: “permission denied while trying to connect to the docker API at unix:///var/run/docker.sock”.

After logging back in, verify:

groups

You should see “docker” in the list.

## 4. Verify Installation

docker --version
docker compose version
docker run hello-world

All three should work without sudo.

## 5. Notes About Password Prompts

If your container setup or Dockerfile uses sudo, you’ll be prompted for your Ubuntu user password. This is the same password you created when launching Ubuntu for the first time.

## 6. Enable NVIDIA GPU Support (WSL or Native Linux)

### 1. Install the NVIDIA GPU Driver (WSL‑only)

Download and install the latest NVIDIA WSL driver from: https://developer.nvidia.com/cuda/wsl

### 2. Install the NVIDIA Container Toolkit (Ubuntu/Pop!_OS/WSL)

distribution=$(. /etc/os-release; echo $ID$VERSION_ID)

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit

nvidia-container-cli --version

### 3. Restart Docker

sudo systemctl restart docker

If systemctl is unavailable (WSL):

sudo service docker restart

### 4. Test GPU Access

docker run --rm --gpus all nvidia/cuda:12.3.2-base-ubuntu22.04 nvidia-smi

You should see your GPU listed.

## 🎉 Done

Docker and Docker Compose are now fully installed and ready to use. Return to the main README for instructions on cloning the repo and running the container.
