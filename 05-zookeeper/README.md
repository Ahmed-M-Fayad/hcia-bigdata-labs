# 02 — ZooKeeper Lab

A real 3-node ZooKeeper ensemble (`zookeeper1`, `zookeeper2`, `zookeeper3`), each a separate container, wired together so trainees see actual leader election and quorum in action instead of a single fake node. This ensemble is what `05-hbase` relies on for cluster coordination later — HBase does not manage its own ZooKeeper in this setup.

## Before you start

Make sure Docker is installed and running — see the [root README](../README.md) if you haven't set that up yet.

This lab is independent of HDFS — it can be started on its own, before or after `03-hdfs`.

## 1. Create the shared network (one-time)

Skip this if you've already created it for another lab:

```bash
docker network create bigdata-net
```

## 2. Start the ensemble

```bash
cd 02-zookeeper
docker compose up -d
```

This starts three containers:

| Container | ZooKeeper ID | Port |
|---|---|---|
| `zookeeper1` | 1 | `2181` (client), `8090` (admin/web) |
| `zookeeper2` | 2 | `2182` (client), `8091` (admin/web) |
| `zookeeper3` | 3 | `2183` (client), `8092` (admin/web) |

Give it 15–20 seconds to elect a leader, then verify all three nodes agree:

```bash
docker exec zookeeper1 zkServer.sh status
docker exec zookeeper2 zkServer.sh status
docker exec zookeeper3 zkServer.sh status
```

You should see exactly one node report `Mode: leader` and the other two report `Mode: follower`. If any node errors out here, fix that before starting anything that depends on this ensemble (namely `05-hbase`) — its own error messages won't point back to this clearly.

## 3. Poke around with the CLI

From any node:
```bash
docker exec -it zookeeper1 zkCli.sh
```
Inside the CLI:
```
ls /
create /lab-test hello
get /lab-test
delete /lab-test
quit
```
This is a good moment to point out that `/lab-test` created via `zookeeper1` is instantly visible from `zookeeper2` or `zookeeper3` too — that's the replicated state trainees will later see HBase relying on.

## 4. Stopping and resetting

Stop the lab (keeps quorum state):
```bash
docker compose stop
```
Start it again later:
```bash
docker compose start
```
Fully reset (wipes ZooKeeper's data — do this if `05-hbase` is also being reset):
```bash
docker compose down -v
docker compose up -d
```

## 5. Notes for Windows users

- If any of `2181`–`2183` or `8090`–`8092` clash with something already running locally, edit the left-hand side of that port mapping in `docker-compose.yml`.
- Order matters for **starting** the ensemble, but not much for **stopping** it — `docker compose stop` shuts all three down together safely regardless of which was the leader.
- If you're also running `05-hbase`, start this lab first and confirm the leader/follower check above before starting HBase — that single check catches most HBase startup failures before they happen.
