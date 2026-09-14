# 01 — Database Essentials & SQL Lab

MySQL 8.0 + Adminer. The database starts **empty** — no tables, no sample data — so trainees build the schema themselves during the session. A ready-made `01-schema-and-data.sql` script is included separately for reference or for speeding things up (e.g. seeding data quickly once the schema concept has been taught).

## Before you start

Make sure Docker is installed and running — see the [root README](../README.md) if you haven't set that up yet.

## 1. Start the lab

From inside this folder:
```bash
cd 01-database
docker compose up -d
```
This starts two containers:
- `db-lab-mysql` — the MySQL 8.0 server, with an empty `company` database ready to use
- `db-lab-adminer` — a web UI for browsing/querying the database

Check both are up:
```bash
docker ps
```

## 2. Start with the UI (Adminer)

Open your browser to:
```
http://localhost:8080
```
Log in with:
| Field | Value |
|---|---|
| System | MySQL |
| Server | `mysql` |
| Username | `root` |
| Password | `root123` |
| Database | `company` |

You'll see the `company` database with no tables yet — that's expected. This is where trainees create tables live.

## 3. Move to the shell (mysql CLI)

```bash
docker exec -it db-lab-mysql mysql -u root -p company
```
Password: `root123`

## 4. Users

Only two accounts exist at this stage:

| User | Password | Access |
|---|---|---|
| `root` | `root123` | Full admin |
| `app_user` | `app123` | Default app-style user (created by the MySQL image itself), full access to `company` |

Extra restricted-privilege users (read-only, project-manager style, etc.) aren't created automatically anymore — introduce `CREATE USER` / `GRANT` as its own teaching moment once the schema exists, using the users as a live example.

## 5. Using the provided schema script (optional, for speed)

`01-schema-and-data.sql` isn't run automatically. If you want to fast-forward to a populated database — e.g. to skip ahead to querying/joins — run it manually:
```bash
docker exec -i db-lab-mysql mysql -u root -p company < 01-schema-and-data.sql
```
Password: `root123`

This creates the `departments`, `employees`, `projects`, and `employee_projects` tables with sample data.

## 6. Stopping and resetting

Stop the lab (keeps your data):
```bash
docker compose stop
```
Start it again later:
```bash
docker compose start
```
Fully reset back to a completely empty database:
```bash
docker compose down -v
docker compose up -d
```

## 7. Notes for Windows users

- If you already have MySQL installed locally (e.g. via XAMPP/WAMP), it likely also uses port `3306` and will clash with this lab. Either stop your local MySQL service first, or edit the `ports:` line in `docker-compose.yml` (e.g. `"3307:3306"`) and connect on the new port instead.
- Adminer at `http://localhost:8080` works the same in any browser on Windows — no extra setup needed.
- If port `8080` is already used by something else on your machine, change the left-hand side of that port mapping the same way (e.g. `"8081:8080"`).
