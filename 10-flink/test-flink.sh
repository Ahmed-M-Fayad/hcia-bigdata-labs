```bash
#!/usr/bin/env bash

set -u

FLINK_API="http://localhost:8091"
JOBMANAGER="flink-jobmanager"

PASS=0
FAIL=0

green() {
    echo -e "\033[32m[PASS]\033[0m $1"
}

red() {
    echo -e "\033[31m[FAIL]\033[0m $1"
}

info() {
    echo -e "\033[36m[INFO]\033[0m $1"
}

pass() {
    PASS=$((PASS + 1))
    green "$1"
}

fail() {
    FAIL=$((FAIL + 1))
    red "$1"
}

echo "=========================================="
echo "       Flink Docker Compose Test"
echo "=========================================="
echo

# ------------------------------------------------------------
# 1. Check Docker containers
# ------------------------------------------------------------

info "Checking Docker containers..."

for container in flink-jobmanager flink-taskmanager1 flink-taskmanager2; do
    if docker inspect -f '{{.State.Running}}' "$container" 2>/dev/null | grep -q true; then
        pass "$container is running"
    else
        fail "$container is NOT running"
    fi
done

echo

# ------------------------------------------------------------
# 2. Check Flink REST API
# ------------------------------------------------------------

info "Checking Flink REST API at $FLINK_API ..."

if curl -fsS "$FLINK_API/overview" >/dev/null 2>&1; then
    pass "Flink REST API is reachable"
else
    fail "Flink REST API is not reachable"
fi

echo

# ------------------------------------------------------------
# 3. Check Flink cluster overview
# ------------------------------------------------------------

info "Checking Flink cluster overview..."

OVERVIEW=$(curl -fsS "$FLINK_API/overview" 2>/dev/null || true)

if [ -z "$OVERVIEW" ]; then
    fail "Could not retrieve Flink cluster overview"
else
    echo "$OVERVIEW" | python3 -m json.tool 2>/dev/null || echo "$OVERVIEW"

    TASKMANAGERS=$(echo "$OVERVIEW" | python3 -c \
        'import sys,json; print(json.load(sys.stdin).get("taskmanagers", -1))' \
        2>/dev/null || echo "-1")

    SLOTS_TOTAL=$(echo "$OVERVIEW" | python3 -c \
        'import sys,json; print(json.load(sys.stdin).get("slots-total", -1))' \
        2>/dev/null || echo "-1")

    SLOTS_AVAILABLE=$(echo "$OVERVIEW" | python3 -c \
        'import sys,json; print(json.load(sys.stdin).get("slots-available", -1))' \
        2>/dev/null || echo "-1")

    if [ "$TASKMANAGERS" = "2" ]; then
        pass "Flink sees 2 TaskManagers"
    else
        fail "Expected 2 TaskManagers, found $TASKMANAGERS"
    fi

    if [ "$SLOTS_TOTAL" = "4" ]; then
        pass "Flink has 4 total task slots"
    else
        fail "Expected 4 total slots, found $SLOTS_TOTAL"
    fi

    if [ "$SLOTS_AVAILABLE" = "4" ]; then
        pass "All 4 task slots are available"
    else
        fail "Expected 4 available slots, found $SLOTS_AVAILABLE"
    fi
fi

echo

# ------------------------------------------------------------
# 4. Check individual TaskManagers
# ------------------------------------------------------------

info "Checking TaskManagers..."

TM_JSON=$(curl -fsS "$FLINK_API/taskmanagers" 2>/dev/null || true)

if [ -z "$TM_JSON" ]; then
    fail "Could not retrieve TaskManager information"
else
    TM_COUNT=$(echo "$TM_JSON" | python3 -c \
        'import sys,json; print(len(json.load(sys.stdin).get("taskmanagers", [])))' \
        2>/dev/null || echo "-1")

    if [ "$TM_COUNT" = "2" ]; then
        pass "REST API reports 2 TaskManagers"
    else
        fail "REST API reports $TM_COUNT TaskManagers"
    fi

    echo
    echo "$TM_JSON" | python3 -m json.tool 2>/dev/null || true
fi

echo

# ------------------------------------------------------------
# 5. Check Flink configuration inside JobManager
# ------------------------------------------------------------

info "Checking JobManager configuration..."

if docker exec "$JOBMANAGER" \
    grep -q "jobmanager.rpc.address: flink-jobmanager" \
    /opt/flink/conf/flink-conf.yaml 2>/dev/null; then

    pass "JobManager RPC address is configured correctly"
else
    fail "JobManager RPC address is not configured correctly"
fi

echo

# ------------------------------------------------------------
# 6. Check TaskManager configuration
# ------------------------------------------------------------

info "Checking TaskManager configuration..."

for container in flink-taskmanager1 flink-taskmanager2; do

    SLOTS=$(docker exec "$container" \
        grep "taskmanager.numberOfTaskSlots" \
        /opt/flink/conf/flink-conf.yaml 2>/dev/null \
        | awk -F: '{gsub(/ /,"",$2); print $2}')

    if [ "$SLOTS" = "2" ]; then
        pass "$container has 2 task slots"
    else
        fail "$container expected 2 task slots, found ${SLOTS:-unknown}"
    fi

    RPC=$(docker exec "$container" \
        grep "jobmanager.rpc.address" \
        /opt/flink/conf/flink-conf.yaml 2>/dev/null || true)

    if echo "$RPC" | grep -q "flink-jobmanager"; then
        pass "$container points to flink-jobmanager"
    else
        fail "$container JobManager RPC address is incorrect"
    fi
done

echo

# ------------------------------------------------------------
# 7. Check connectivity from TaskManagers to JobManager
# ------------------------------------------------------------

info "Checking TaskManager -> JobManager connectivity..."

for container in flink-taskmanager1 flink-taskmanager2; do

    if docker exec "$container" \
        getent hosts flink-jobmanager >/dev/null 2>&1; then

        pass "$container can resolve flink-jobmanager"
    else
        fail "$container cannot resolve flink-jobmanager"
    fi

done

echo

# ------------------------------------------------------------
# 8. Test Flink REST endpoints
# ------------------------------------------------------------

info "Testing important REST endpoints..."

ENDPOINTS=(
    "/overview"
    "/taskmanagers"
    "/jobs"
    "/config"
)

for endpoint in "${ENDPOINTS[@]}"; do

    if curl -fsS "$FLINK_API$endpoint" >/dev/null 2>&1; then
        pass "GET $endpoint"
    else
        fail "GET $endpoint"
    fi

done

echo

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

echo "=========================================="
echo "              TEST SUMMARY"
echo "=========================================="
echo
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo

if [ "$FAIL" -eq 0 ]; then
    green "ALL TESTS PASSED"
    exit 0
else
    red "$FAIL TEST(S) FAILED"
    exit 1
fi
```