# HCIA Big Data Training Labs

Hands-on Docker Compose labs for the NTI Huawei HCIA Big Data Associate program. Each numbered folder is one lab.

## What you need

- **Git** — to clone this repo and pull new labs as they're pushed.
- **Docker** — every lab runs inside containers, so this is the only real dependency. No need to install Linux, MySQL, Hadoop, etc. on your machine directly.

## Installing Docker

**Windows:**
1. Install **Docker Desktop**: https://www.docker.com/products/docker-desktop/
2. Docker Desktop needs **WSL2** as its backend. If the installer doesn't set this up automatically, follow Microsoft's guide: https://learn.microsoft.com/en-us/windows/wsl/install
3. Virtualization must be enabled in your BIOS (usually is, by default, on modern PCs).
4. After install, open Docker Desktop and make sure it says "Engine running" before continuing.
5. Run all commands in this repo from **PowerShell**, **Windows Terminal**, or a **WSL** shell — not the old `cmd.exe`.

**Linux (Ubuntu/Debian):**
1. Follow the official install guide: https://docs.docker.com/engine/install/ubuntu/
2. Add yourself to the `docker` group so you don't need `sudo` for every command:
   ```bash
   sudo usermod -aG docker $USER
   ```
   Then log out and back in.

Verify it worked (same command on both OSes):
```bash
docker --version
docker compose version
```

## Getting the labs

Clone the repo once:
```bash
git clone <repo-url>
cd hcia-bigdata-labs
```

New labs get added and updated as we progress through the program. Before each session, pull the latest:
```bash
git pull
```

## Running a lab

Each lab lives in its own numbered folder (`00-linux`, `01-database`, `02-python`, and onward through the Big Data stack). Go into the folder for the topic we're covering and follow **that folder's own README.md** — it has the exact setup steps and any tool-specific notes.

General pattern for any lab:
```bash
cd 00-linux
docker compose up -d --build
```

## A note for Windows users

Most of you are on Windows; I'm on Ubuntu. Everything here is built to work identically on both through Docker, but wherever a step genuinely differs between Windows and Linux (line endings, terminal choice, file paths, etc.), it will be called out inside that specific lab's README — not here.

## Getting help

If a lab doesn't come up cleanly, run `docker compose logs` inside that lab's folder and bring the output to class or ask on the group.
