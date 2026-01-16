#!/bin/bash

# Quit on failure:
set -euo pipefail

# Log color.
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Print a log a message with timestamp.
log ()
{
    printf "${GREEN}$(date +'%m.%d.%y %H:%M:%S'): $1${NC}\n"
}


root_check() {
    log "Checking root access..."
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root" >&2
        exit 1
    fi
}

# Update Proxmox packadges and kernel:
add_pve_repositories() {
    # Enterprise envs:
    local SOURCES_LOCATION="/etc/apt/sources.list.d"
    local ENTERPRISE_LIST_FILE="$SOURCES_LOCATION/pve-enterprise.sources"
    local NO_SUB_REPO_LIST_FILE="$SOURCES_LOCATION/proxmox.sources"
    local ENABLED_FALSE="Enabled: false"

    log "Checking for repositories..."

    if [ -f "$ENTERPRISE_LIST_FILE" ] && ! grep -q "$ENABLED_FALSE" "$ENTERPRISE_LIST_FILE"; then
        log "Disabling Enterprise PVE repository."
        echo "$ENABLED_FALSE" >> "$ENTERPRISE_LIST_FILE"
    fi

    if [ ! -f "$NO_SUB_REPO_LIST_FILE" ]; then  
        log "Creating No-Subscription Proxmox source."
        cat <<EOF > "$NO_SUB_REPO_LIST_FILE"
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
    else
        log "No-Subscription repository already enabled."
    fi
}

update_pve() {
    # Run updates
    log "Running Proxmox updates!"
    if pveupdate && pveupgrade; then
        log "Update succeded!"
    else
        log "Update failure!"
        exit 1
    fi
}

reboot_pve() {
    # Reboot the entire system after.
    if [ -f /var/run/reboot-required ]; then
        log "Rebooting the system!"
        reboot now 
    fi
}

main() {
    # Run everything:
    root_check
    add_pve_repositories
    update_pve
    reboot_pve
}

main

# To-Do:
# 1. User / Roles and permissions provisioning.
# 2. SSH keys and SSH connection permissions.
# 3. Data center level Firewall Configuration.
# 4. Proxmox Auto-Update feature script.
# 5. SSL certificate configuration.
# 6. 2FA configuration.
# 7. Drives and Storage configuration - where to store images / templates etc...
# 8. Initial Network configuration.
# 9. Terraform configurarion - Creating Terraform User.
# 10. Ansible configuration - user and permission creation.
