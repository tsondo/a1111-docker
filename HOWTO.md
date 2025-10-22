# 🐧 Installing Docker in WSL (Ubuntu 22.04)

Follow these steps to set up Docker inside WSL. Once complete, your containers will auto‑start as described in the main README.

---

## 1. Install WSL with Ubuntu 22.04

Open **PowerShell as Administrator** and run:

```powershell
wsl --install -d Ubuntu-22.04
```

If WSL is already installed, ensure Ubuntu‑22.04 is set to version 2:

```powershell
wsl --set-version Ubuntu-22.04 2
```

Then launch **Ubuntu 22.04** from the Start menu and create your Linux username and password.

> 📝 This password is important — you’ll use it whenever `sudo` asks for authentication.

---

## 2. Install Docker Inside Ubuntu

Open your Ubuntu terminal and run:

```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine and Compose plugin
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

## 3. Add Your User to the Docker Group

To run Docker without `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Now you can run Docker commands like `docker ps` without `sudo`.

---

## 4. Verify Installation

```bash
docker --version
docker compose version
```

Both commands should print version numbers.

---

## 5. Notes About Password Prompts

- If your container setup or Dockerfile uses `sudo`, you’ll be prompted for your **Ubuntu user password**.
- This is the same password you created when launching Ubuntu for the first time.

---

## 6. Enable NVIDIA GPU Support in WSL

To use GPU acceleration inside Docker containers:

### 1. Install the NVIDIA GPU Driver for WSL on Windows

Download and install the latest [NVIDIA WSL driver](https://developer.nvidia.com/cuda/wsl). This enables GPU passthrough into WSL.

### 2. Install the NVIDIA Container Toolkit in Ubuntu

Run the following in your Ubuntu terminal:

```bash
# Detect your distribution
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)

# Add NVIDIA GPG key
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

# Add NVIDIA repository
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
  | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Install the toolkit
sudo apt update
sudo apt install -y nvidia-container-toolkit
```

> ✅ This setup ensures you get **version 1.17.x or newer**, which is required for modern NVIDIA drivers.  
> Run `nvidia-container-cli --version` to verify.

### 3. Restart the Docker Daemon

```bash
sudo systemctl restart docker
```

> ⚠️ If `systemctl` fails, try:
```bash
sudo service docker restart
```

### 4. Test GPU Access

Run:

```bash
docker run --rm --gpus all nvidia/cuda:12.3.2-base-ubuntu22.04 nvidia-smi
```

You should see your GPU listed.

---

✅ That’s it — Docker is ready. Head back to the main README for instructions on cloning the repo and running the container.
