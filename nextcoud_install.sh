#!/bin/bash
# version 0.0.2
# Author: Jaime Galvez
#&COPY;2024 
#GNU/GPL Licence
#Date: November-2024
# Script to install Apache, PHP, MySQL server, MySQL client, Certbot, Bind9, Nextcloud, and required configurations to set up the server.
# Clear terminal
clear

# Interactive menu for capturing values

echo "=========================================================="
echo "============ Nextcloud Configuration ====================="
echo "=========================================================="
echo ""
# Check if the user is root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." 
    exit 1
fi

# Prompt for Nextcloud version
read -p "Which version of Nextcloud would you like to install? (Default: 29.0.0): " NEXTCLOUD_VERSION
NEXTCLOUD_VERSION=${NEXTCLOUD_VERSION:-"29.0.0"}  # Default version if user inputs nothing

# Prompt for database name
read -p "Enter the database name (default: nextcloud_db): " DB_NAME
DB_NAME=${DB_NAME:-"nextcloud_db"}

# Prompt for database user
read -p "Enter the database user name (default: nextcloud_user): " DB_USER
DB_USER=${DB_USER:-"nextcloud_user"}

# Prompt for database password
read -sp "Enter the password for the database user: " DB_PASSWORD
echo

# Prompt for Nextcloud installation path
read -p "Enter the Nextcloud installation path (default: /var/www/html/nextcloud): " NEXTCLOUD_PATH
NEXTCLOUD_PATH=${NEXTCLOUD_PATH:-"/var/www/html/nextcloud"}

# Prompt for domain or IP
read -p "Enter the domain or IP to access Nextcloud: " DOMAIN

# Configuration confirmation
echo -e ""
echo -e "========================================================"
echo -e "============ Configuration Summary: ===================="
echo -e "========================================================"
echo -e ""

echo "Nextcloud Version: $NEXTCLOUD_VERSION"
echo "Database: $DB_NAME"
echo "Database User: $DB_USER"
echo "Installation Path: $NEXTCLOUD_PATH"
echo "Domain or IP: $DOMAIN"
echo -e "Do you want to proceed with the installation? (y/n): "

# Confirmation to proceed with the installation
read -n 1 CONFIRM
echo
if [[ "$CONFIRM" != [yY] ]]; then
    echo "Installation canceled."
    exit 1
fi

# Rest of the script for Nextcloud installation
# Update and upgrade packages
echo "=================================================="
echo "========= Updating system... ====================="
echo "=================================================="
apt update && apt upgrade -y

# Install Apache
echo "Installing Apache..."
apt install apache2 -y
ufw allow 'Apache Full'

# Install MariaDB
echo "Installing MariaDB..."
apt install mariadb-server -y
mysql_secure_installation

# Create database and user for Nextcloud
echo "Configuring database for Nextcloud..."
mysql -u root -e "CREATE DATABASE ${DB_NAME};"
mysql -u root -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Add repository for PHP 8.1
echo "Adding repository for PHP 8.1..."
sudo add-apt-repository ppa:ondrej/php -y

# Install PHP 8.1 and necessary modules
echo "Installing PHP 8.1 and modules..."
PHP_MODULES="php8.1 php8.1-mysql php8.1-xml php8.1-mbstring php8.1-curl php8.1-gd php8.1-intl php8.1-zip php8.1-xmlrpc php8.1-imagick php8.1-bcmath php8.1-gmp php-apcu"
sudo apt install "$PHP_MODULES"

# Configure PHP for Nextcloud
echo "Configuring PHP..."
PHP_INI_PATH=$(php -r "echo php_ini_loaded_file();")
sed -i "s/memory_limit = .*/memory_limit = 512M/" "$PHP_INI_PATH"
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 512M/" "$PHP_INI_PATH"
sed -i "s/post_max_size = .*/post_max_size = 512M/" "$PHP_INI_PATH"
sed -i "s/max_execution_time = .*/max_execution_time = 300/" "$PHP_INI_PATH"

# Download and configure Nextcloud
echo "Downloading Nextcloud..."
wget https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2
tar -xjf nextcloud-${NEXTCLOUD_VERSION}.tar.bz2
mv nextcloud $NEXTCLOUD_PATH
chown -R www-data:www-data $NEXTCLOUD_PATH
chmod -R 755 $NEXTCLOUD_PATH

# Configure Apache for Nextcloud
echo "Configuring Apache for Nextcloud..."
cat <<EOL > /etc/apache2/sites-available/nextcloud.conf
<VirtualHost *:80>
    ServerAdmin admin@$DOMAIN
    DocumentRoot $NEXTCLOUD_PATH
    ServerName $DOMAIN

    <Directory $NEXTCLOUD_PATH>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
        <IfModule mod_dav.c>
            Dav off
        </IfModule>
        SetEnv HOME $NEXTCLOUD_PATH
        SetEnv HTTP_HOME $NEXTCLOUD_PATH
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog \${APACHE_LOG_DIR}/nextcloud_access.log combined
</VirtualHost>
EOL

# Enable Nextcloud configuration and necessary Apache modules
a2ensite nextcloud.conf
a2enmod rewrite headers env dir mime setenvif
systemctl restart apache2

# Finish
echo "Nextcloud installation complete."
echo "Please access http://$DOMAIN to complete setup in the browser."

