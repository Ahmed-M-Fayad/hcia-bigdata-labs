# 03 — HDFS Lab

The foundation of the whole Big Data track: a single-namenode, three-datanode HDFS cluster. Every lab from here on (`03-mapreduce-yarn`, `04-hive`, `05-hbase`, ...) reads and writes through this same cluster, so it needs to be up first and stay up while those labs run.

## Before you start

Make sure Docker is installed and running — see the [root README](../README.md) if you haven't set that up yet.

## 1. Create the shared network (one-time)

Every Hadoop-stack lab shares one Docker network so containers can resolve each other by name. Create it once — skip this if you've already done it for another lab:

```bash
docker network create bigdata-net
```

## 2. Start the cluster

From inside this folder:
```bash
cd 03-hdfs
docker compose up -d
```

This starts four containers:

| Container | Role | Port |
|---|---|---|
| `namenode` | HDFS master — filesystem metadata, web UI | `9870` (web UI), `8020` (RPC — this is what every other lab connects to) |
| `datanode` | Data node 1 | `9864` |
| `datanode2` | Data node 2 | `9865` (mapped from the container's `9864`) |
| `datanode3` | Data node 3 | `9866` (mapped from the container's `9864`) |

Check they're all up:
```bash
docker ps
```
Give the namenode a minute to leave safe mode. `docker ps` marks the Hadoop images as `healthy` once their internal health check passes — wait for that before starting a dependent lab (`03-mapreduce-yarn`, `04-hive`, `05-hbase`), since they all check for `namenode:9870` and `datanode:9864` on startup and will exit if those aren't reachable yet.

## 3. Web UI

```
http://localhost:9870
```
Shows the cluster's overview, live datanodes, and lets you browse the filesystem under **Utilities → Browse the file system**.

## 4. Basic HDFS commands

From inside the namenode container:
```bash
docker exec -it namenode hadoop fs -ls /
docker exec -it namenode hadoop fs -mkdir /lab
docker exec -it namenode hadoop fs -put /etc/hosts /lab/hosts.txt
docker exec -it namenode hadoop fs -cat /lab/hosts.txt
```

## 5. Stopping and resetting

Stop the lab (keeps your data):
```bash
docker compose stop
```
Start it again later:
```bash
docker compose start
```
Fully reset (wipes everything stored in HDFS — do this if `03-mapreduce-yarn`, `04-hive`, or `05-hbase` are also being reset, since their data lives here):
```bash
docker compose down -v
docker compose up -d
```

## 6. Notes for Windows users

- If port `9870`, `8020`, `9864`, `9865`, or `9866` is already in use by something else, edit the left-hand side of that port mapping in `docker-compose.yml`.
- The web UI at `http://localhost:9870` works the same in any browser — no extra setup needed.
- This lab is the dependency for several others, so plan to leave it running for the rest of the session rather than stopping it between topics.
