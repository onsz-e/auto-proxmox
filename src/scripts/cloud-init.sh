#!/bin/bash

set -euo pipefail

mkdir -p $IMAGES_DIR

wget -nc $DEBIAN_IMAGE_SOURCE -P $IMAGES_DIR

qm create $QM_ID --name $VM_NAME

qm set $QM_ID --scsi0 local-lvm:0,import-from=$IMAGES_DIR/$DEBIAN_IMAGE

qm template $QM_ID
