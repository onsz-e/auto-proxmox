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
        
        ;;
    *)
        echo "There is no such option."
        ;;
    esac
}

menu