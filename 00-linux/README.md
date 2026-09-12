# 00 — Linux Essentials Lab

A realistic multi-user Ubuntu 22.04 server environment, running in a container, for practicing users, groups, and permissions.

## Before you start

Make sure Docker is installed and running — see the [root README](../README.md) if you haven't set that up yet.

## 1. Build and start the lab

From inside this folder:
```bash
cd 00-linux
docker compose up -d --build
```
This builds the image (first time only takes a minute or two) and starts a container called `linux-lab` that stays running in the background.

Check it's up:
```bash
docker ps
```
You should see `linux-lab` with status "Up".

## 2. Get inside the container

```bash
docker exec -it linux-lab bash
```
This drops you in as `root` by default. To practice as one of the training users instead, switch with `su`:
```bash
su - ahmed_admin
```

## 3. Training users

The lab comes with several pre-created accounts so every permission concept has a real example to test on. All passwords are simple on purpose — this is a lab, not production.

| User | Group | Sudo? | Password |
|---|---|---|---|
| `root` | — | full | `root123` |
| `ahmed_admin` | `sysadmins` | yes (password required) | `admin123` |
| `sara_dev` | `developers` | no | `dev123` |
| `omar_dev` | `developers` | no | `dev123` |
| `intern_user` | `interns` | no | `intern123` |

`sara_dev` and `omar_dev` share the `developers` group on purpose, so you can test group-shared access between two different people, not just "user vs root."

## 4. Pre-built playground

A few directories are already set up with real-world-style ownership and permissions so you can explore them with `ls -l`, `chmod`, `chown`, and `find`:

- `/opt/company-data` — root-owned, locked down (`700`)
- `/srv/shared-dev` — group-owned by `developers`, setgid so new files inherit the group
- `/srv/reports` — owned by `ahmed_admin`, group-writable, world-readable
- `/var/log/lab-app` — a few log files with deliberately mixed permissions

## 5. Stopping and resetting

Stop the lab (keeps your data):
```bash
docker compose stop
```
Start it again later:
```bash
docker compose start
```
Fully reset everything (wipes any changes you made inside the container):
```bash
docker compose down -v
docker compose up -d --build
```

## 6. Notes for Windows users

- Run all of the above from **PowerShell**, **Windows Terminal**, or **WSL** — everything is Linux-only *inside* the container, so your host OS doesn't matter beyond having Docker running.
- If you cloned this repo with Git's default settings on Windows, text files may have Windows-style line endings (CRLF). That doesn't affect anything here since we're not editing files inside the container from the host, but if you ever get a `bad interpreter` or `\r` error in a later lab, that's the cause.
- No ports are exposed by this lab, so there's nothing to configure in Docker Desktop's network/firewall settings for this one.

## 7. No internet, if you want it

By default the container has internet access (for `apt`, `curl`, `ping` demos). If you want to practice fully offline, open `docker-compose.yml`, comment out the `networks:` line under `linux-lab`, and uncomment `network_mode: none`. Then rebuild with `docker compose up -d --build`.
