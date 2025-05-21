# Dockerfile
# Start from the official WordPress image
FROM wordpress:latest

# Explicitly copy all WordPress core files from the base image's source location
# to the /var/www/html directory in your new image.
# The --chown flag ensures they have the correct www-data ownership right away.
# COPY --chown=www-data:www-data /usr/src/wordpress/ /var/www/html/

# Copy your custom scripts and Apache configurations into this new image.
# This makes your custom setup part of the image itself, which is cleaner.
COPY ./enable-ssl.sh /usr/local/bin/enable-ssl.sh
COPY ./install-packages.sh /usr/local/bin/install-packages.sh
COPY ./apache-conf/ssl.conf /etc/apache2/sites-available/ssl.conf
COPY ./apache-conf/ssl.conf.template /etc/apache2/sites-available/ssl.conf.template

# Make sure your scripts are executable.
RUN chmod +x /usr/local/bin/enable-ssl.sh \
    /usr/local/bin/install-packages.sh