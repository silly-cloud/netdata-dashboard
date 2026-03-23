#!/bin/bash
# setup.sh — Install and configure Netdata on Ubuntu/Debian
# Netdata's official installer handles: dependencies, repo setup, install, and daemon start

set -e  # Exit immediately if any command fails — critical for setup scripts

echo "==> Updating package lists..."
apt-get update -y

# wget fetches the official kickstart script — this is Netdata's recommended install method
# It auto-detects your distro, sets up the apt repo, and installs the agent
echo "==> Installing Netdata via official kickstart script..."
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
sh /tmp/netdata-kickstart.sh --non-interactive  # --non-interactive skips prompts

# Verify the service started correctly
# systemctl is-active returns exit code 0 if active, non-zero if not
if systemctl is-active --quiet netdata; then
    echo "==> Netdata is running."
else
    echo "==> Netdata failed to start. Check: journalctl -u netdata"
    exit 1
fi

# --- Custom Alert: CPU usage > 80% ---
# Netdata stores health alarm configs in /etc/netdata/health.d/
# Each .conf file can define one or more alarms
# We append to cpu.conf (or create it if missing)
ALERT_FILE="/etc/netdata/health.d/cpu_alert.conf"

cat > "$ALERT_FILE" << 'EOF'
# Alert fires when average CPU usage over 1 minute exceeds 80%
alarm: cpu_usage_high
    on: system.cpu          # which chart to watch
lookup: average -1m         # average value over last 1 minute
  every: 10s                # check every 10 seconds
  warn: $this > 80          # WARNING if > 80%
  crit: $this > 90          # CRITICAL if > 90%
  info: CPU usage is high
EOF

echo "==> CPU alert configured at $ALERT_FILE"

# Reload Netdata to pick up the new alarm without full restart
# kill -USR2 sends a reload signal — Netdata re-reads config files
kill -USR2 "$(pidof netdata)"

echo ""
echo "==> Setup complete."
echo "    Dashboard: http://$(hostname -I | awk '{print $1}'):19999"
