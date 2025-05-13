#!/bin/bash
set -e

echo "Enabling SSL for Apache..."
# Set default values if environment variables aren't provided
: ${SSL_CERT_FILE:="/etc/apache2/ssl/wordpress.crt"}
: ${SSL_KEY_FILE:="/etc/apache2/ssl/wordpress.key"}

echo "Using SSL certificate: $SSL_CERT_FILE"
echo "Using SSL key: $SSL_KEY_FILE"


# Process the template and create the actual config file
envsubst '${SSL_CERT_FILE} ${SSL_KEY_FILE}' < /etc/apache2/sites-available/ssl.conf.template > /etc/apache2/sites-available/ssl.conf

echo "SSL configuration file created at /etc/apache2/sites-available/ssl.conf"


# Enable SSL module and site
a2enmod ssl
a2ensite ssl.conf

# Set ServerName globally to avoid warning
echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Test the configuration
apache2ctl configtest

# No need to restart Apache here as it will be started by the entrypoint
echo "SSL configuration complete with certificates:"
echo " - Certificate: $SSL_CERT_FILE"
echo " - Key: $SSL_KEY_FILE"