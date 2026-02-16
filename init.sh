#!/bin/bash

set -e

menu() {
    echo """
###HELLO###
For more information about each option head to: 

REMEMBER TO COPY .ENV!
- 
###MENU###
1) Basic PVE configuration.

What do you want to do?
"""

    read OPTION < /dev/tty

    case "$OPTION" in
    1)
        curl -sSL https://raw.githubusercontent.com/onsz-e/auto-proxmox/main/src/scripts/basic-pve-configuration.sh | bash
        ;;
    *)
        echo "There is no such option!"
        ;;
    esac
}

menu