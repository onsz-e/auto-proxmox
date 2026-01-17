#!/bin/bash

# Quit on failure:
set -euo pipefail

# Log color.
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Global Environemnt variables:
GITHUB_URL="https://raw.githubusercontent.com/onsz-e/auto-proxmox/main/src"

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

# Check for Proxmox version compatibility.
pve_version_check() {
    local PVE_VERSION='proxmox-ve: 9'

    log "Checking Proxmox compatibility."
    if pveversion -v | grep "$PVE_VERSION"; then
        log "Proxmox version compatible."
    else
        log "YOUR PROXMOX VERSION IS NOT COMPATIBLE! EXITING THE SCRIPT!"
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

# Run updates:
update_pve() {
    log "Running Proxmox updates!"
    pveupdate
    pveupgrade
    log "Update succeeded!"
}

# Install additional packages:
install_packages() {
    log "Installing additional packages!"
    apt-get install -y --ignore-missing \
        vim \
        htop \
        tcpdump \
        lsof \
        git
}

# Enable SMART Disk monitoring if avaiable.
enable_smart() {
    log "Checking storage layout."
    pvesm status
    lsblk

    #log "Trying to enable SMART monitoring."
    #systemctl enable --now smartd
    #smartctl -a /dev/sda
}

# Configures SSH
configure_ssh() {
    log "Configuring SSHD"
    local SSHDPATH="/etc/ssh/sshd_config.d"
    local CONFIGS_PATH="configs/sshd"

    if compgen -G "$SSHDPATH/*.conf" > /dev/null; then
        log "$SSHDPATH is not empty!"
    else
        log "Fetching config files..."
        curl -sS -fL "$GITHUB_URL/$CONFIGS_PATH"/10-auth.conf.sh > "$SSHDPATH"/10-auth.conf
        curl -sS -fL "$GITHUB_URL/$CONFIGS_PATH"/20-root.conf.sh > "$SSHDPATH"/20-root.conf
        curl -sS -fL "$GITHUB_URL/$CONFIGS_PATH"/30-hardening.conf.sh > "$SSHDPATH"/30-hardening.conf
    
        log "Reloading SSH..."
        systemctl reload ssh
    fi
}

# Crontab configuration...
cron_jobs() {
    local CRON_DIR="/etc/cron.d"
    local CRON_AUTOUPDATE="$CRON_DIR/auto-update"

    log "Configuring cron jobs!"
    curl -sS -fL "$GITHUB_URL"/cron/auto-update > "$CRON_AUTOUPDATE"

    log "Setting permissions."
    chown root:root "$CRON_AUTOUPDATE"
    chmod 0664 "$CRON_AUTOUPDATE"
}

datacenter_firewall() {
    log "Configuring Datacenter lever Firewall."

    local DC_FIRWALL="/etc/pve/firewall"
    
    if compgen -G "$DC_FIRWALL/*.fw" > /dev/null; then
        log "Firewall already turned on!"
    else
        curl -sS -fL "$GITHUB_URL"/configs/firewall/30-hardening.conf.sh > "$DC_FIRWALL"/cluster.fw
        systemctl reload pve-firewall
        log "Succesfully configured Datacenter Firewall!"
    fi
}

# Updates message of the day.
update_motd() {
    local MOTD_FILE="/etc/motd"
    local DYN_MOTD="/etc/update-motd.d/99-proxmox"

    log "Checking for an exisiting static motd file..."
    if -f "$MOTD_FILE"; then
        rm -f "$MOTD_FILE"
        log "Deleted static motd file. Proceeding with creation."
    else
        log "Nothing to delete... Proceed with creation"
    
    fi
    log "Fetching the script."
    curl -sS -fL "$GITHUB_URL"/configs/motd > "$DYN_MOTD"
    
    log "Enabling script execution."
    chmod +x /etc/update-motd.d/99-proxmox
}

# Root bashrc configuration.
bashrc_conf() {
    local BASHRC_FILE="/root/.bashrc"

    log "Configuring bashrc file."
    curl -sS -fL "$GITHUB_URL"/configs/bashrc > "$BASHRC_FILE"
}

# Reboot the entire system after.
reboot_pve() {
    if [ -f /var/run/reboot-required ]; then
        log "Rebooting the system!"
        reboot now 
    fi
}

# Main Function to run everything.
main() {
    root_check
    pve_version_check
    add_pve_repositories
    update_pve
    enable_smart
    configure_ssh
    datacenter_firewall
    update_motd
    cron_jobs
    bashrc_conf
    reboot_pve
}

main

# To-Do:
# Prepare report from the script, after all run.

### Extended version
# 1. Adding SSH key mechanism - user input
#. 2. Additional user creation - user input
# 3. 2FA configuration. - user input
# 9. Terraform configurarion - Creating Terraform User.
# 10. Ansible configuration - user and permission creation.
# Setting custom Git repository for configs - idk maybe some local way of backing up config files like ssh and firewall.
# Remove unused services like bluetooth and such...
# Create a snapshoot of PRoxmox host after initial configuration.
# 7. Drives and Storage configuration - where to store images / templates etc...
# 5. SSL certificate configuration.
# Adding EMAIL alers!
# 1. Roles and permissions provisioning.
# 8. Initial Network configuration.

# Improvements:
# 1. Better package installation. Add for loop?
# 2. Fix smartd monitoring - it's disabled...
# 3. Better cronjobs handling... It's unsafe.