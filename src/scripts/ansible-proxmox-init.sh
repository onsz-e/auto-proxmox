#!/bin/bash
set -euo pipefail

LOG_FILE="./run-$(date +%F_%H%M%S).log"
exec >>"$LOG_FILE" 2>&1

if pveum user list | grep -q "$ANSIBLE_USER_NAME"; then
    echo "User $ANSIBLE_USER_NAME already created"
else
    pveum role add "$ANSIBLE_ROLE_NAME" -privs "VM.Audit Sys.Audit"
    pveum user add "$ANSIBLE_USER_NAME"@"$ANSIBLE_PVE_REALM" --password "$ANSIBLE_PASSWORD"
    pveum aclmod / -user "$ANSIBLE_USER_NAME"@"$ANSIBLE_PVE_REALM" -role "$ANSIBLE_ROLE_NAME"
    pveum user token add "$ANSIBLE_USER_NAME"@"$ANSIBLE_PVE_REALM" "$ANSIBLE_API_TOKEN" --privsep 0
fi