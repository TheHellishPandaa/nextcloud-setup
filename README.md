<h1><strong>Nextcloud Installation Script</strong></h1>

This script automates the installation of Nextcloud along with Apache, MariaDB, PHP, and other necessary services. Designed for Ubuntu-based systems, it sets up a fully functional Nextcloud instance with minimal manual intervention.
Prerequisites

    Root Access: This script must be executed with root privileges.
    Supported System: Ubuntu 20.04 or newer (adjustments may be required for other distributions).

## Installation

Clone the Repository (or copy the script directly from this repository):

```bash
git clone https://github.com/TheHellishPandaa/nextcloud_install.git
```
```bash
cd nextcloud_install
```
Make the Script Executable:

chmod +x nextcloud_install.sh

Run the Script as Root:

    sudo ./nextcloud_install.sh

Script Configuration

The script will prompt you for several configuration settings. You can simply press Enter to accept default values for any of these options:

    Nextcloud Version: Version of Nextcloud to install (default: 29.0.0).
    Database Name: Name of the database for Nextcloud (default: nextcloud_db).
    Database User: User for the Nextcloud database (default: nextcloud_user).
    Database Password: Password for the Nextcloud database user.
    Installation Path: Path to install Nextcloud (default: /var/www/html/nextcloud).
    Domain or IP: Domain or IP address to access Nextcloud.

After entering these details, you will see a summary. Confirm by entering s (yes) to proceed or any other key to cancel the installation.
Usage

Once installed, you can access Nextcloud by navigating to http://your-domain-or-ip in a web browser. Follow the on-screen prompts to complete the Nextcloud setup.
Troubleshooting

    Apache Not Restarting: Ensure all dependencies were installed correctly. Check for any error messages and verify that ports are not blocked by the firewall.
    Database Connection Issues: Double-check the database name, username, and password you entered during setup. Ensure MariaDB is running and configured correctly.
    Domain Configuration: If you encounter issues with accessing Nextcloud, verify that your domain or IP is correctly configured and DNS is properly set up.

License

This project is licensed under the GNU General Public License v3.0.
