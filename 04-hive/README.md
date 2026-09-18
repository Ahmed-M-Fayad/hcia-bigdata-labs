# 04 — Hive Lab

Apache Hive 2.3.2 running on top of the shared Hadoop cluster, with a PostgreSQL-backed metastore instead of the default embedded Derby one. Three containers work together: `hive-metastore-postgresql` (the metastore's database), `hive-metastore` (the Thrift metastore service), and `hive-server` (HiveServer2, what you actually connect to and run HiveQL against).

## Before you start

Make sure Docker is installed and running — see the [root README](../README.md) if you haven't set that up yet.

This lab does **not** run standalone — Hive stores its data in HDFS, so the `03-hdfs` lab (namenode + datanodes) must already be up first.

## 1. Create the shared network (one-time)

Every lab from this point on (`03-hdfs`, `04-hive`, `05-hbase`, ...) shares one Docker network so containers can resolve each other by name. Create it once — you only need to do this the very first time:

```bash
docker network create bigdata-net
```

If it already exists, Docker will just tell you so; that's fine.

## 2. Start HDFS first

```bash
cd 03-hdfs
docker compose up -d
```

Give the namenode a minute to leave safe mode, then confirm it's healthy:

```bash
docker ps
```

You want `namenode` and `datanode` showing `Up` (ideally `healthy`) before moving on. Hive's containers check for `namenode:9870` and `datanode:9864` on startup and will exit if they can't reach them.

## 3. Start Hive

```bash
cd ../04-hive
docker compose up -d
```

This starts:

| Container | Role | Port |
|---|---|---|
| `hive-metastore-postgresql` | Postgres database backing the metastore | internal only |
| `hive-metastore` | Thrift metastore service | `9083` |
| `hive-server` | HiveServer2 — JDBC + web UI | `10000` (JDBC), `10002` (web UI) |

Check everything came up and stayed up:

```bash
docker ps
```

If `hive-metastore` or `hive-server` exit shortly after starting, it's almost always because their `SERVICE_PRECONDITION` couldn't be satisfied — check `docker logs hive-metastore` and `docker logs hive-server`, and confirm the previous step's containers are actually healthy.

## 4. Connect with Beeline

```bash
docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000
```

Once connected:

```sql
SHOW DATABASES;
CREATE DATABASE lab;
USE lab;
```

## 5. Load the sample data

`trip_records.csv` (vehicle trip records — trip id, vehicle, driver, start/end time, distance, fuel used) is included in this folder for practicing `CREATE TABLE` and `LOAD DATA`. Copy it into the container first:

```bash
docker cp trip_records.csv hive-server:/tmp/trip_records.csv
```

Then, back in Beeline:

```sql
CREATE TABLE trips (
  trip_id INT,
  vehicle_id STRING,
  driver_name STRING,
  start_time STRING,
  end_time STRING,
  distance_km DOUBLE,
  fuel_used DOUBLE,
  city STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
TBLPROPERTIES ("skip.header.line.count"="1");

LOAD DATA LOCAL INPATH '/tmp/trip_records.csv' INTO TABLE trips;

SELECT * FROM trips;
```

**Heads up:** the CSV's header row has one fewer column than the data rows (there's no header for the last column), and several city values are truncated (`Cair`, `Alexan`, `Giza`...) instead of consistent full names. This is deliberate rough data — good material for a "does my schema actually match my data" or basic data-cleaning discussion once the `LOAD DATA` step is done.

## 6. Web UI

HiveServer2's web UI (session info, active queries) is at:
```
http://localhost:10002
```

## 7. Stopping and resetting

Stop the lab (keeps your data):
```bash
docker compose stop
```
Start it again later:
```bash
docker compose start
```
Fully reset (wipes the metastore database and any tables you created):
```bash
docker compose down -v
docker compose up -d
```

## 8. Notes for Windows users

- Ports `9083`, `10000`, and `10002` are unlikely to clash with anything else, but if one does, edit the left-hand side of that port mapping in `docker-compose.yml`.
- If you edited `trip_records.csv` on Windows before copying it in, watch out for CRLF line endings — Hive will treat the trailing `\r` as part of the last field's value. If rows look odd after `LOAD DATA`, that's usually why.
