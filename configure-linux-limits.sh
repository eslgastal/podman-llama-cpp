#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   sudo bash configure-linux-limits.sh
#   bash configure-linux-limits.sh USERNAME  # as root

if (( EUID != 0 )); then
    echo "Error: run this script as root." >&2
    exit 1
fi

TARGET_USER="${1:-${SUDO_USER:-}}"

if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
    echo "Error: specify the regular user as an argument." >&2
    exit 1
fi

if [[ ! "$TARGET_USER" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*\$?$ ]]; then
    echo "Error: invalid username." >&2
    exit 1
fi

if ! id "$TARGET_USER" &>/dev/null; then
    echo "Error: user '$TARGET_USER' does not exist." >&2
    exit 1
fi

CONF="/etc/security/limits.d/90-llama-${TARGET_USER}.conf"

cat > "$CONF" <<EOF
# llama.cpp resource limits for ${TARGET_USER}

# Allow locking model weights in physical RAM.
${TARGET_USER} soft memlock unlimited
${TARGET_USER} hard memlock unlimited

# Permit --prio 2: process nice value -10.
${TARGET_USER} soft nice -10
${TARGET_USER} hard nice -10

# Permit --prio 2: SCHED_FIFO priority 80 for CPU threads.
${TARGET_USER} soft rtprio 80
${TARGET_USER} hard rtprio 80
EOF

chmod 0644 "$CONF"

echo "Configured resource limits for $TARGET_USER:"
cat "$CONF"

echo
echo "Log out completely and log back in to apply the limits."
echo "Restart existing tmux sessions before launching llama-server."
echo
echo "Verify as $TARGET_USER:"
echo "  ulimit -l  # unlimited"
echo "  ulimit -e  # 30 (allows nice -10)"
echo "  ulimit -r  # 80"
