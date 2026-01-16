#!/bin/bash

set -e

menu() {
    echo """
###HELLO###
For more information about each option head to: 
- 
###MENU###
1) Basic PVE configuration.

What do you want to do?
"""

    read OPTION

    case "$OPTION" in
    1)
        TMP_SCRIPT=$(mktemp)
        curl -sSL https://raw.githubusercontent.com/onsz-e/proxmox-configuration/main/src/basic-pve-configuration.sh -o "$TMP_SCRIPT"
        chmod +x "$TMP_SCRIPT"
        bash "$TMP_SCRIPT"
        rm -f "$TMP_SCRIPT"
        ;;
    *)
        echo "There is no such option."
        ;;
    esac
}

menu