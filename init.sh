#!/bin/bash

set -e

menu() {
    echo """
###HELLO###
For more information about each option head to: 
- 
###MENU###
1) Basic PVE configuration.
"""

    read OPTION

    case "$OPTION" in
    1)
        curl -sSL https://raw.githubusercontent.com/onsz-e/proxmox-configuration/main/src/basic-pve-configuration.sh | bash;
        menu
        ;;
    *)
        echo "There is no such option.";
        menu
        ;;
    esac
}

menu