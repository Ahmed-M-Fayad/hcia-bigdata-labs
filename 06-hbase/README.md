# 05 — HBase Lab

Apache HBase 1.2.6 running in **distributed mode** on top of the shared HDFS cluster, coordinated by an external 3-node ZooKeeper ensemble (`HBASE_MANAGES_ZK=false` — HBase does not run its own embedded ZooKeeper here, on purpose, so you can see how a real cluster is wired together). One `hbase-master` plus two region servers.

## Before you start

Make sure Docker is installed and running — see the [root README](../README.md) if you haven't set that up yet.

This lab depends on **two** other labs being up first: `03-hdfs` and `02-zookeeper`. HBase will not start without both.

## 1. Create the shared network (one-time)

Skip this if you've already created it for another lab (e.g. `03-hdfs` or `04-hive`):

```bash
docker network create bigdata-net
```

## 2. Start HDFS

```bash
cd 03-hdfs
docker compose up -d
```

Confirm `namenode` and `datanode` are `Up`/`healthy` with `docker ps` before continuing.

## 3. Start the ZooKeeper ensemble

```bash
cd ../02-zookeeper
docker compose up -d
```

Give it 15–20 seconds to elect a leader, then verify all three nodes actually agree on their roles:

```bash
docker exec zookeeper1 zkServer.sh status
docker exec zookeeper2 zkServer.sh status
docker exec zookeeper3 zkServer.sh status
```

You should see exactly one `leader` and two `follower`. **This step matters — it's the most common reason HBase fails to start.** If any node errors out or they don't agree, fix that before moving on; HBase's own error messages further down the line won't point back to this clearly.

## 4. Start HBase

```bash
cd ../05-hbase
docker compose up -d
```

This starts:

| Container | Role | Port |
|---|---|---|
| `hbase-master` | HMaster — cluster coordinator, web UI | `16010` (web UI), `16000` (RPC) |
| `hbase-regionserver1` | Region server | `16030` |
| `hbase-regionserver2` | Region server | `16031` (mapped from the container's `16030`, since `hbase-regionserver1` already claims `16030` on the host) |

Check nothing exited:

```bash
docker ps -a
```

`hbase-master` and both region servers check `SERVICE_PRECONDITION` (namenode, datanode, and the ZooKeeper quorum — plus `hbase-master` itself, for the region servers) before starting HBase itself, and will exit if any of those aren't reachable in time. If something exits shortly after starting, check:

```bash
docker logs hbase-master
docker logs hbase-regionserver1
```

A log stuck on "Waiting for ..." means a precondition host isn't reachable (usually ZooKeeper — go back to step 3). A Java stack trace instead means it got past the precondition check but hit a config or connectivity problem afterward.

## 5. Web UI

```
http://localhost:16010
```

Shows cluster status, the two live region servers, and any tables you create.

## 6. HBase shell

```bash
docker exec -it hbase-master hbase shell
```

A quick smoke test:

```
create 'test', 'cf'
put 'test', 'row1', 'cf:a', 'value1'
scan 'test'
disable 'test'
drop 'test'
```

## 7. Stopping and resetting

Stop the lab (keeps your data):
```bash
docker compose stop
```
Start it again later — **in the same dependency order as above** (ZooKeeper needs to already be running):
```bash
docker compose start
```
Fully reset (wipes HBase's data in HDFS on next start, since `hbase-rootdir` points at `hdfs://namenode:8020/hbase`):
```bash
docker compose down -v
docker compose up -d
```

## 8. Notes for Windows users

- If port `16030` is already in use by something else, edit the left-hand side of the `hbase-regionserver1` port mapping in `docker-compose.yml` the same way it's already done for `hbase-regionserver2`.
- Startup order really matters here more than in most labs — if you ever run `docker compose up -d` from `05-hbase` without ZooKeeper already healthy, don't be surprised to see `hbase-master` exit with status `1` a minute or two later. Just start ZooKeeper, confirm it's healthy, then re-run `docker compose up -d` in this folder.
