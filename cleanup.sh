#!/bin/bash
# cleanup.sh — Stop and fully remove Netdata from the system

set -e

echo "==> Stopping Netdata service..."
systemctl stop netdata || true   # '|| true' prevents set -e from exiting if already stopped

echo "==> Removing Netdata package..."
# apt-get purge removes the package AND its config files (unlike 'remove' which keeps configs)
apt-get purge -y netdata netdata-core netdata-plugins-bash netdata-plugins-python 2>/dev/null || true

echo "==> Removing leftover files and directories..."
# Netdata stores data, logs, and config across several directories
rm -rf /etc/netdata \
       /var/lib/netdata \
       /var/cache/netdata \
       /var/log/netdata \
       /usr/lib/netdata \
       /usr/share/netdata

echo "==> Removing netdata user and group..."
userdel netdata 2>/dev/null || true
groupdel netdata 2>/dev/null || true

echo "==> Running autoremove to clean orphaned dependencies..."
apt-get autoremove -y

echo ""
echo "==> Cleanup complete. Netdata has been fully removed."
