#!/bin/bash

# pick up the environment variables from the .env file
# and export them to the current shell
# This is necessary for the docker compose command to work
# without having to pass them as arguments
set -a
source .env
set +a

echo "🔄 Waiting for the database to be ready..."
until docker compose run --rm wpcli db check > /dev/null 2>&1; do
  sleep 2
done

echo "✅ Database is ready."

if docker compose run --rm wpcli core is-installed; then
  echo "✅ WordPress is already installed."
else
  echo "🚀 Installing WordPress..."
  echo "email:"
  echo $WORDPRESS_DB_USER
  echo "-------------"
  docker compose run --rm wpcli core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"
fi

# Set WordPress options after installation
# docker compose run --rm wpcli option update siteurl "${WP_URL}"
# docker compose run --rm wpcli option update home "${WP_URL}"

echo "✅ WordPress installation completed."