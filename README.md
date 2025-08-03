
# Run Multiple Nexus Nodes on Ubuntu

This guide explains how to run multiple Nexus nodes locally on Ubuntu or VPS. Ideal for those with limited resources who still want to participate in testing and scaling the Nexus infrastructure.

---

## Features

- Auto-launch multiple nodes in parallel using `tmux`
- Auto-restart crashed nodes with exponential backoff
- Uses `taskset` and `nice` for CPU and priority control
- Auto-start on system boot with `systemd`
- Swap support for low-RAM devices

---

## Requirements

- Ubuntu 22.04+ (desktop or server)
- 2+ CPU cores, 4–8 GB RAM minimum
- SSD strongly recommended
- Internet connection

---

## Clone this repository

```bash
git clone https://github.com/kvrniawan/Nexus-Node.git
cd Nexus-Node
```

---

## Step-by-Step Setup

### 1. Update and Install Required Tools

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl tmux build-essential net-tools htop sysstat pkg-config libssl-dev git protobuf-compiler -y
```

---

### 2. Install Nexus CLI

```bash
curl https://cli.nexus.xyz/ | sh
```

Make it globally accessible:

```bash
echo 'export PATH="$HOME/.nexus/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

### 3. Edit `nodes.txt`

```bash
nano nodes.txt
```

Fill this file with your Node IDs (one per line).

Save with `Ctrl+O` then `Enter`, exit with `Ctrl+X`.

---

### 4. Make the launcher script executable

```bash
chmod +x launch_nodes.sh
```

---

### 5. (Optional) Add Swap for RAM-Limited Systems

```bash
sudo fallocate -l 100G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Performance tuning:

```bash
sudo sysctl vm.swappiness=60
echo 'vm.swappiness=60' | sudo tee -a /etc/sysctl.conf

sudo sysctl vm.vfs_cache_pressure=50
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
```

---

### 6. Edit Nexus Service (Optional For Autostart on Boot)

This step is optional.  
If you want Nexus nodes to start automatically when your system boots, configure the systemd service as shown below.  
If you already have this set up or don’t need autostart, you can skip this step.

```bash
sudo cp ~/Nexus-Node/nexus.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
```

---

### 7. Run the Nodes Manually (if not using systemd autostart)

```bash
bash launch_nodes.sh
tmux attach-session -t nexus
```

If the terminal freezes, press `Ctrl+C` and then run:

```bash
tmux attach-session -t nexus
```

To navigate tmux windows:

- Next window: `Ctrl+B`, then `N`  
- Previous window: `Ctrl+B`, then `P`  
- Detach session: `Ctrl+B`, then `D`

---

### 8. To Stop All Nodes

If running via systemd:

```bash
sudo systemctl stop nexus
```

If running manually, just exit tmux or kill the session:

```bash
tmux kill-session -t nexus
```

---

### 9. Managing Node IDs (Adding or Removing Nodes)

If you want to add or remove node IDs in `nodes.txt`, **stop the Nexus service first**:

```bash
sudo systemctl stop nexus
```

Edit the file:

```bash
nano ~/Nexus-Node/nodes.txt
```

After saving changes, restart the service:

```bash
sudo systemctl start nexus
```

Check status:

```bash
sudo systemctl status nexus
```

*Always stop the service before editing `nodes.txt` to avoid duplicate nodes or conflicts.*

---

## Credits

Made with ❤️ for the Nexus community.

