# 02 — Python + MySQL Integration Demo

A live, instructor-driven demo bridging the **01-database** lab with Python: the same
`company` schema, queried from a Python script instead of Adminer or the `mysql` CLI.

This lab is **self-contained** — it spins up its own MySQL + Adminer, pre-loaded with the
schema and sample data (so the demo isn't blocked on trainees' 01-database containers
still being up). Nothing is installed on the host: MySQL, Adminer, and Python all run in
containers.

This is meant to be **watched, not typed along with** — one instructor-driven run, not a
per-trainee exercise. If a future session adds hands-on time, trainees can run the exact
same steps themselves on their own machines with zero changes.

## Before you start

Make sure Docker is installed and running — see the [root README](../README.md) if you
haven't set that up yet.

## 1. Start the lab

From inside this folder:
```bash
cd 02-python-integration
docker compose up -d --build
```
This starts three containers:
- `pyint-lab-mysql` — MySQL 8.0, with the `company` database already populated
  (departments/employees/projects/employee_projects — same data as 01-database)
- `pyint-lab-adminer` — optional web UI, useful to show the tables before/after the demo
- `pyint-lab-python` — a Python container with pandas, SQLAlchemy, and PyMySQL installed,
  just idling until you run the demo script

Check all three are up:
```bash
docker ps
```

## 2. (Optional) confirm the data is there via Adminer

```
http://localhost:8080
```
| Field | Value |
|---|---|
| System | MySQL |
| Server | `mysql` |
| Username | `root` |
| Password | `root123` |
| Database | `company` |

You should see populated `departments`, `employees`, `projects`, and `employee_projects`
tables — a nice "look, it's the same data" moment before switching to Python.

## 3. Run the demo, live

```bash
docker exec -it pyint-lab-python python demo_query.py
```

This runs the *exact same* employees–departments JOIN trainees already wrote by hand in
the SQL session — but now the result lands directly in a pandas DataFrame inside Python.
It then writes that DataFrame back into MySQL as a new `employees_backup` table, as an
optional "SQL → Python → SQL" round trip if time allows.

Talking point while it runs: Adminer has been connecting to MySQL by container name
(`mysql`) over Docker's internal network the entire time — this script is doing exactly
the same trick, just from Python instead of a browser.

## 4. Stopping and resetting

Stop the lab (keeps your data):
```bash
docker compose stop
```
Start it again later:
```bash
docker compose start
```
Fully reset back to the original seeded state:
```bash
docker compose down -v
docker compose up -d --build
```

## 5. Notes for Windows users

- Same port-conflict note as 01-database: if something local already uses `3306` or
  `8080`, edit the left-hand side of the relevant `ports:` line in `docker-compose.yml`
  (e.g. `"3307:3306"`) and adjust the demo/Adminer connection accordingly.
- No local Python, pip installs, or MySQL client needed on the host at all — everything
  runs inside the three containers above.
