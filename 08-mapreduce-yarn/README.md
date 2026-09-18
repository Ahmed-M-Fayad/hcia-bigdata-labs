# 03 — MapReduce / YARN Lab

YARN running on top of the shared HDFS cluster: one `resourcemanager` and two `nodemanager`s, so trainees can actually submit and watch a distributed job run across more than one worker.

## Before you start

Make sure Docker is installed and running — see the [root README](../README.md) if you haven't set that up yet.

This lab depends on `03-hdfs` being up first — YARN's containers check for `namenode:9870` and `datanode:9864` on startup and will exit if they can't reach them.

## 1. Create the shared network (one-time)

Skip this if you've already created it for another lab:

```bash
docker network create bigdata-net
```

## 2. Start HDFS first

```bash
cd 03-hdfs
docker compose up -d
```

Confirm `namenode` and `datanode` are `Up`/`healthy` with `docker ps` before continuing.

## 3. Start YARN

```bash
cd ../03-mapreduce-yarn
docker compose up -d
```

This starts:

| Container | Role | Port |
|---|---|---|
| `resourcemanager` | YARN master — schedules jobs, web UI | `8088` |
| `nodemanager` | Worker node 1 | `8042` |
| `nodemanager2` | Worker node 2 | `8043` (mapped from the container's `8042`) |

Check nothing exited:
```bash
docker ps -a
```
If a node manager exits shortly after starting, check `docker logs nodemanager` — it's almost always the `resourcemanager:8088` precondition not being ready yet, or HDFS from the previous step not actually being healthy.

## 4. Web UI

```
http://localhost:8088
```
Shows the resource manager's cluster overview, both node managers, and any applications submitted below.

## 5. Run a sample MapReduce job

The Hadoop image ships with the classic example jar, so you can submit a real distributed job with no extra setup — a word count against a file you put in HDFS:

```bash
docker exec -it namenode hadoop fs -mkdir -p /input
docker exec -it namenode hadoop fs -put /etc/hosts /input/hosts.txt

docker exec -it resourcemanager hadoop jar \
  /opt/hadoop-3.2.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar \
  wordcount /input /output

docker exec -it namenode hadoop fs -cat /output/part-r-00000
```
Watch the job progress live at `http://localhost:8088` while it runs — a good moment to point out the job actually gets split across `nodemanager` and `nodemanager2`.

## 6. Stopping and resetting

Stop the lab (keeps your data):
```bash
docker compose stop
```
Start it again later:
```bash
docker compose start
```
Fully reset:
```bash
docker compose down -v
docker compose up -d
```

## 7. Notes for Windows users

- If port `8088`, `8042`, or `8043` is already in use by something else, edit the left-hand side of that port mapping in `docker-compose.yml`.
- The word count example above uses `/etc/hosts` purely because it's a small text file that's guaranteed to exist inside the container — feel free to substitute any text file you like.
