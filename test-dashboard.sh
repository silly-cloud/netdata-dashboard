#!/bin/bash
# test_dashboard.sh — Generate synthetic load to verify the dashboard is working
# Open http://<ip>:19999 in your browser BEFORE running this, then watch metrics spike

set -e

DURATION=60  # seconds to run each load test

echo "==> Starting load test. Open Netdata dashboard to watch metrics."
echo "    Dashboard: http://$(hostname -I | awk '{print $1}'):19999"
echo ""

# --- CPU Load ---
# 'yes' outputs "y" infinitely fast — pure CPU burn
# We run one process per CPU core (nproc) and background all of them (&)
# 'timeout' kills each process after $DURATION seconds
echo "==> [1/3] CPU load for ${DURATION}s (using $(nproc) cores)..."
for i in $(seq 1 "$(nproc)"); do
    timeout "$DURATION" yes > /dev/null &
done
# Wait for all background CPU jobs to finish before moving on
wait
echo "    CPU load done."

# --- Memory Load ---
# 'stress-ng' is a dedicated load-testing tool
# --vm 2         → 2 virtual memory stressor processes
# --vm-bytes 256M → each allocates 256MB (512MB total)
# --timeout       → run for this many seconds
echo "==> [2/3] Memory load for ${DURATION}s..."
if ! command -v stress-ng &>/dev/null; then
    echo "    Installing stress-ng..."
    apt-get install -y stress-ng -q
fi
stress-ng --vm 2 --vm-bytes 256M --timeout "${DURATION}s" --quiet
echo "    Memory load done."

# --- Disk I/O Load ---
# dd reads from /dev/urandom (random bytes) and writes to a temp file
# bs=1M  → block size 1MB
# count=512 → 512 blocks = 512MB written
# conv=fdatasync → forces flush to disk (so it actually hits the disk, not just cache)
echo "==> [3/3] Disk I/O load..."
dd if=/dev/urandom of=/tmp/netdata_test_file bs=1M count=512 conv=fdatasync status=progress
rm -f /tmp/netdata_test_file
echo "    Disk I/O load done."

echo ""
echo "==> Load test complete. Check Netdata dashboard for metric spikes."
