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

## Windows setup checklist (do all of these, in order)

1. **BIOS — enable virtualization** (Docker won't run without this):
   - Restart PC → enter BIOS/UEFI (`Del`, `F2`, `F10`, or `Esc` at boot).
   - Find **Intel VT-x** / **Intel Virtualization Technology** / **AMD-V** / **SVM Mode** (under *Advanced*, *CPU*, or *Security*) → **Enable** → Save (`F10`) → reboot.
   - Managed/work laptop and option greyed out → ask IT to enable it.
   - Verify: Task Manager (`Ctrl+Shift+Esc`) → Performance → CPU → **Virtualization: Enabled**.

2. **Install/enable WSL2** — PowerShell **as Administrator**:
   ```powershell
   wsl --install
   wsl --set-default-version 2
   ```
   Restart the PC (required). Already had WSL? Update instead:
   ```powershell
   wsl --update
   wsl --shutdown
   ```
   `wsl --install` failed (old Windows build)? Run, then restart:
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

3. **Install Docker Desktop**: https://www.docker.com/products/docker-desktop/
   - Settings → General → **"Use the WSL 2 based engine"** ✅
   - Settings → Resources → WSL Integration → toggle your distro ✅ → Apply & Restart

4. **Verify everything works**, in order:
   ```powershell
   wsl --status
   ```
   ```bash
   docker --version
   docker compose version
   docker run hello-world
   ```
   If `hello-world` prints its message, you're done. If any command fails, fix it now — don't start a lab yet.

## Error → fix

| Error | Fix |
|---|---|
| `0x80370102` / "required feature is not installed" | Virtualization off in BIOS → step 1 |
| `WSL 2 requires an update to its kernel component` | `wsl --update` |
| `Wsl/Service/CreateInstance/HCS_E_...` | Update VirtualBox/VMware to latest, or disable conflicting antivirus |
| Docker Desktop stuck on "Starting..." | `wsl --shutdown`, quit Docker Desktop fully, reopen |
| `docker: command not found` in WSL terminal | Enable WSL Integration for your distro (step 3) |
| Can't reach `localhost:<port>` | Use `127.0.0.1`; check firewall/VPN |
| `$'\r': command not found` in scripts | `git config --global core.autocrlf input`, or `dos2unix script.sh` |
| WSL using all your RAM | `%UserProfile%\.wslconfig`:<br>`[wsl2]`<br>`memory=4GB`<br>`processors=2`<br>then `wsl --shutdown` |

## Getting help

If a lab doesn't come up cleanly, run `docker compose logs` inside that lab's folder and bring the output to class or ask on the group.
