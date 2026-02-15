# 🔨 Archforge

Offload AUR package compilation from a low-power machine to a powerful build server over your local network.

Instead of waiting hours for your thin client or mini PC to compile packages, **archforge** transparently sends builds to your powerful desktop, compiles inside Docker, and returns the built `.pkg.tar.zst` — all without changing your workflow.

## How It Works

```
Client (weak machine)                      Server (powerful machine)
─────────────────────                      ──────────────────────────
paru / yay / topgrade
  └─▶ makepkg (wrapper)
        └─▶ archforge-remote  ──SSH+rsync──▶  archforge
                                                └─▶ Docker container
                                                      └─▶ makepkg -sf
              ◀──rsync── .pkg.tar.zst ◀────────────────┘
```

The wrapper intercepts every `makepkg` call. Query flags (`--packagelist`, `--printsrcinfo`) pass through to the real makepkg so AUR helpers work correctly. Actual builds are offloaded to the server.

## Components

| File | Where | Purpose |
|---|---|---|
| `archforge` | Server | Runs the Docker build |
| `archforge-remote` | Client | Sends source to server, retrieves built package |
| `archforge-makepkg` | Client | Universal `makepkg` wrapper (installed as `/usr/local/bin/makepkg`) |
| `Dockerfile` | Server | Docker image with `base-devel`, multilib, and CachyOS repos |

## Setup

### Prerequisites

- Two Arch Linux machines on the same network
- **Server:** Docker installed and running
- **Client:** `rsync` and `openssh`

---

### 1. Server

```bash
# Install Docker if not already installed
sudo pacman -S docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# Log out and back in for group change to take effect

# Clone and build
git clone https://github.com/YOUR_USER/archforge.git
cd archforge
docker build -t archforge .

# Install the server script
sudo install -m 755 archforge /usr/local/bin/archforge
```

#### Verify

```bash
git clone https://aur.archlinux.org/yay-bin.git /tmp/test-build
archforge /tmp/test-build
# Should print: [✓] Build completado con éxito!
rm -rf /tmp/test-build
```

---

### 2. SSH Keys

The client needs passwordless SSH access to the server.

```bash
# On the client:
ssh-keygen -t ed25519 -N ""           # Skip if you already have a key
ssh-copy-id YOUR_USER@SERVER_IP       # Copy key to server

# Verify:
ssh -o BatchMode=yes YOUR_USER@SERVER_IP "echo OK"
```

---

### 3. Client

```bash
git clone https://github.com/YOUR_USER/archforge.git
cd archforge
```

#### 3.1 Configure the server address

Edit `archforge-remote` and set your server's IP and username:

```bash
BUILD_SERVER="192.168.x.x"    # Your server's LAN IP
BUILD_USER="your_username"     # Your user on the server
```

#### 3.2 Install

```bash
sudo install -m 755 archforge-remote /usr/local/bin/archforge-remote
sudo install -m 755 archforge-makepkg /usr/local/bin/makepkg
```

> **How it works:** `/usr/local/bin` has PATH priority over `/usr/bin`, so our wrapper runs instead of the system `makepkg`. The real one stays untouched at `/usr/bin/makepkg`.

#### 3.3 Verify

```bash
# Check PATH priority
type -a makepkg
# makepkg is /usr/local/bin/makepkg    ← wrapper
# makepkg is /usr/bin/makepkg          ← real

# Test a build
git clone https://aur.archlinux.org/yay-bin.git /tmp/test-build
cd /tmp/test-build && makepkg
# Should compile on the server and return the package
```

---

### 4. Use it

Nothing changes in your workflow:

```bash
topgrade          # AUR builds go to the server
paru -Syu         # Same
yay -Syu          # Same
makepkg           # Same
```

## Docker Image

The included `Dockerfile` sets up:

- `archlinux:base-devel` as base image
- **multilib** repo (for `lib32-*` packages needed by Wine, Proton, etc.)
- **CachyOS** repo (for additional packages not in standard Arch repos)
- `git` and `sudo` pre-installed
- A `builder` user with passwordless sudo
- Pacman database sync before each build

## Uninstall

**Client:**
```bash
sudo rm /usr/local/bin/makepkg /usr/local/bin/archforge-remote
```

**Server:**
```bash
sudo rm /usr/local/bin/archforge
docker rmi archforge
```

## Troubleshooting

| Problem | Solution |
|---|---|
| `target not found: some-package` | Add the missing repo to `Dockerfile`, rebuild with `docker build -t archforge .` |
| SSH asks for password | Run `ssh-copy-id user@server` on the client |
| Wrapper not active | Check `type -a makepkg` — first entry should be `/usr/local/bin/makepkg` |
| paru: `can't find package name in packagelist` | Update `archforge-makepkg` — it must pass `--packagelist` to real makepkg |

## License

MIT
