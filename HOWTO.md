# Installing Docker + NVIDIA Container Toolkit

This guide walks you through installing Docker Engine, the Compose plugin, and the NVIDIA Container Toolkit so you can run GPU-accelerated containers. Pick your platform below.

---

## 1. Install Docker Engine + Compose

<details>
<summary><strong>Ubuntu / Debian</strong></summary>

```bash
# Install prerequisites
sudo apt update
sudo apt install -y ca-certificates curl

# Add Docker's official GPG key
# For Debian, replace "ubuntu" with "debian" in the two URLs below
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Add the Docker repo
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine + Compose plugin
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

> **Tip:** If the `echo ... | sudo tee` line fails with a password prompt error,
> run `sudo -v` first to cache your credentials, then re-run the command.

</details>

<details>
<summary><strong>Fedora</strong></summary>

```bash
# Add the Docker repo
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

# Install Docker Engine + Compose plugin
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable the Docker service
sudo systemctl enable --now docker
```

</details>

<details>
<summary><strong>Arch Linux</strong></summary>

```bash
# Install from the official Arch repos
sudo pacman -S docker docker-compose docker-buildx

# Start and enable the Docker service
sudo systemctl enable --now docker
```

</details>

<details>
<summary><strong>Windows (WSL2)</strong></summary>

Docker Desktop handles the engine for you — no need to install Docker inside WSL manually.

1. Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. During setup, enable **WSL2 integration**
3. If you don't have WSL yet, open PowerShell as Administrator:

```powershell
wsl --install -d Ubuntu
```

4. Launch Ubuntu from the Start menu and create your Linux username and password
5. Open Docker Desktop → Settings → Resources → WSL Integration → enable your distro

Docker commands will now work inside your WSL terminal. Skip ahead to [Section 3](#3-add-your-user-to-the-docker-group) below.

</details>

---

## 2. Add Your User to the Docker Group

This lets you run `docker` commands without `sudo`:

```bash
sudo usermod -aG docker $USER
```

**You must log out and back in** (or reboot) for this to take effect. Then verify:

```bash
groups           # should list "docker"
docker run hello-world   # should work without sudo
```

---

## 3. Install the NVIDIA Container Toolkit

This is required for GPU passthrough (`--gpus all`). You need an NVIDIA GPU driver already installed on the host.

> **WSL users:** Install the [NVIDIA WSL driver](https://developer.nvidia.com/cuda/wsl) on the Windows side first. Do NOT install a GPU driver inside WSL — Windows handles this.

<details>
<summary><strong>Ubuntu / Debian / WSL (apt)</strong></summary>

```bash
# Download the GPG key
curl -fsSL -o /tmp/nvidia-container-toolkit.gpg https://nvidia.github.io/libnvidia-container/gpgkey
sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg /tmp/nvidia-container-toolkit.gpg

# Download and add the repo list
curl -s -L -o /tmp/nvidia-container-toolkit.list https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list
sed -i 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' /tmp/nvidia-container-toolkit.list
sudo cp /tmp/nvidia-container-toolkit.list /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Install
sudo apt update
sudo apt install -y nvidia-container-toolkit
```

</details>

<details>
<summary><strong>Fedora / RHEL (dnf)</strong></summary>

```bash
# Download and add the repo file
curl -s -L -o /tmp/nvidia-container-toolkit.repo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
sudo cp /tmp/nvidia-container-toolkit.repo /etc/yum.repos.d/nvidia-container-toolkit.repo

# Install
sudo dnf install -y nvidia-container-toolkit
```

</details>

<details>
<summary><strong>Arch Linux</strong></summary>

```bash
# Available from the AUR
yay -S nvidia-container-toolkit
# or: paru -S nvidia-container-toolkit
```

</details>

After installing on any distro, configure the Docker runtime and restart:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

WSL users without `systemctl`:

```bash
sudo service docker restart
```

---

## 4. Verify Everything

```bash
docker --version
docker compose version
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi
```

The last command should print your GPU name and driver version. If it does, you're ready — head back to the [README](README.md) to set up the project.

---

## Troubleshooting

**"permission denied while trying to connect to the Docker daemon socket"**
You haven't logged out since adding yourself to the `docker` group. Log out and back in, or run `newgrp docker` in your current shell.

**"docker: Error response from daemon: could not select device driver"**
The NVIDIA Container Toolkit isn't installed or Docker hasn't been restarted since installing it. Run the install steps in Section 3 above.

**"Failed to initialize NVML: Unknown Error" (WSL)**
Make sure you installed the NVIDIA WSL driver on the *Windows* side, not inside WSL. Restart WSL with `wsl --shutdown` from PowerShell, then try again.
