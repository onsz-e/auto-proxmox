#!/bin/bash

set -e

TMP_SCRIPT=$(mktemp)
curl -sSL https://raw.githubusercontent.com/onsz-e/proxmox-configuration/main/src/start.sh -o "$TMP_SCRIPT"
chmod +x "$TMP_SCRIPT"
bash "$TMP_SCRIPT"
rm -f "$TMP_SCRIPT"