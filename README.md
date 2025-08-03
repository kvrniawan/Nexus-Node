# Run Multiple Nexus Nodes on Ubuntu

This guide explains how to run multiple Nexus nodes locally on Ubuntu or VPS . Ideal for those with limited resources who still want to participate in testing and scaling Nexus infrastructure.

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

## Step-by-Step Setup

### 1. Update and Install Required Tools

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl tmux build-essential net-tools htop sysstat -y
sudo apt install build-essential pkg-config libssl-dev git-all
sudo apt install protobuf-compiler
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

### 3. Edit `nodes.txt`
```bash
nano nodes.txt
```
Edit and fill with your NodeID's.

Save with `Ctrl+X` then `Y` and enter

### 4. Make it executable:
```bash
chmod +x launch_nodes.sh
```

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


### 6. Edit Nexus Service (Optional For Autostart when launch)
```bash
sudo nano /etc/systemd/system/nexus.service
```
Edit <YOUR_USERNAME> and fill with your username

to get your username 
```bash
whoami
```
### 7. Run the Nodes

```bash
bash launch_nodes.sh
tmux attach-session -t nexus
```
After doing this step if your terminal freezed just type `Ctrl+C` then enter.
And do this again too see what running
```bash
tmux attach-session -t nexus
```

See Multiple Windows on tmux `Ctrl+B`, Then `N` for next and `P` for previous.

Detach: `Ctrl+B`, then `D`

---
Do this step if you doing on step 6, just skip if you don't.

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
```

### 8. Stop all process
```bash
sudo systemctl stop nexus
```
---
## Credits

Made with ❤️ for the Nexus community.
