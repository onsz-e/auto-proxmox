#!/bin/bash

set -e

TMP_SCRIPT=$(mktemp)
echo 'curl -sSL https://raw.githubusercontent.com/onsz-e/auto-proxmox/main/src/start.sh' >> "$TMP_SCRIPT"
chmod +x "$TMP_SCRIPT"
bash "$TMP_SCRIPT"
rm -f "$TMP_SCRIPT"