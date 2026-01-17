# Auto-Proxmox

Automated configuration script for Proxmox Virtual Environment (PVE) that streamlines the initial setup and hardening of your Proxmox server with best practices and security configurations.

## What It Does

This automation script provides a comprehensive initial configuration for Proxmox VE, including:

- **Security Hardening**
  - Configures SSH with hardened settings (authentication, root access, and security parameters)
  - Sets up datacenter-level firewall rules
  - Disables password authentication and enables key-based SSH login

- **System Updates**
  - Disables Enterprise repository (requires subscription)
  - Enables No-Subscription repository for free updates
  - Updates system packages and Proxmox kernel

- **Essential Tools Installation**
  - vim (text editor)
  - htop (process monitor)
  - tcpdump (network analyzer)
  - lsof (file and process information)
  - git (version control)

- **System Monitoring**
  - SMART disk monitoring configuration
  - Storage layout verification

- **Automated Maintenance**
  - Configures automatic system updates via cron jobs
  - Sets up scheduled maintenance tasks

- **User Experience**
  - Custom Message of the Day (MOTD) for login screens
  - Enhanced root bashrc configuration
  - Improved terminal experience

- **Automatic Reboot**
  - Reboots the system if required after updates

## Compatibility

| Proxmox Version | Debian Codename | Status |
|----------------|-----------------|--------|
| 9.x            | Trixie          | ✅ Tested & Compatible |
| 8.x and older  | -               | ❌ Not Compatible |

**Note:** This script is specifically designed and tested for Proxmox VE 9 (Trixie). Using it on other versions may cause unexpected behavior or errors.

## Quick Start

### Prerequisites

- Fresh Proxmox VE 9 (Trixie) installation
- Root access to the Proxmox server
- Internet connection

### Installation

Run the script directly from GitHub using curl:

```bash
curl -sSL https://raw.githubusercontent.com/onsz-e/auto-proxmox/main/init.sh | bash
```

### What Happens Next

1. The script presents an interactive menu
2. Select "1" for Basic PVE configuration
3. The script will automatically:
   - Verify Proxmox version compatibility
   - Configure repositories
   - Update the system
   - Apply security hardening
   - Install essential tools
   - Configure automated maintenance
   - Reboot if necessary

## Features in Detail

### SSH Configuration
- Disables password authentication
- Configures root access restrictions
- Applies security hardening measures
- Configuration files stored in `/etc/ssh/sshd_config.d/`

### Firewall Setup
- Datacenter-level firewall configuration
- Automatic firewall rule deployment
- Configuration stored in `/etc/pve/firewall/`

### Automated Updates
- Cron job for automatic system updates
- Configuration stored in `/etc/cron.d/auto-update`

## Important Notes

⚠️ **Warning:** This script makes significant changes to your Proxmox system. It is recommended to:
- Use on fresh installations
- Review the script before running
- Have console access in case SSH configuration changes lock you out
- Ensure you have SSH keys configured before disabling password authentication

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## Support

For issues and questions, please use the [GitHub Issues](https://github.com/onsz-e/auto-proxmox/issues) page.