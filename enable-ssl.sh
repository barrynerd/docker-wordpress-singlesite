#!/bin/bash
set -e

# Enable SSL module and site
a2enmod ssl
a2ensite ssl.conf

# Set ServerName globally to avoid warning
echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Test the configuration
apache2ctl configtest

# No need to restart Apache here as it will be started by the entrypoint
echo "SSL configuration complete"