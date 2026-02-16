#!/bin/bash
set -euo pipefail

LOG_FILE="./run-$(date +%F_%H%M%S).log"
exec >>"$LOG_FILE" 2>&1

if pveum user list | grep -q "$TF_USER_NAME"; then
    echo "User $TF_USER_NAME already created"
else
    pveum role add "$TF_ROLE_NAME" -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Pool.Audit Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"
    pveum user add "$TF_USER_NAME"@"$TF_PVE_REALM" --password "$TF_PASSWORD"
    pveum aclmod / -user "$TF_USER_NAME"@"$TF_PVE_REALM" -role "$TF_ROLE_NAME"
    pveum user token add "$TF_USER_NAME"@"$TF_PVE_REALM" "$TF_API_TOKEN"
fi