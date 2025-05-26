#!/bin/bash

# pick up the environment variables from the .env file
# and export them to the current shell
# This is necessary for the docker compose command to work
# without having to pass them as arguments
set -a
source .env
set +a

echo "🔄 Waiting for the database to be ready..."
# until docker compose run --rm wpcli db check > /dev/null 2>&1; do
until docker compose run --rm wpcli db check ; do

  sleep 2
done

echo "✅ Database is ready."

if docker compose run --rm wpcli core is-installed; then
  echo "✅ WordPress is already installed."
else
  echo "🚀 Installing WordPress..."
  echo "email: ${WP_ADMIN_EMAIL}"
  echo "user: ${WP_ADMIN_USER}"
  echo "-------------"
  docker compose run --rm wpcli core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"
fi

# Set WordPress options after installation
# These are already set, but you can uncomment them if you want to change them
# or use as a model for other changes
# docker compose run --rm wpcli option update siteurl "${WP_URL}"
# docker compose run --rm wpcli option update home "${WP_URL}"

echo "✅ WordPress installation completed."

if [ "$INSTALL_PLUGINS" ] ; then
  echo "🚀 Installing plugins..."
  ./scripts/plugins_install.sh
else
  echo "🚫 Skipping plugin installation."
fi
echo "✅ Plugin installation completed."

# Set WordPress options after installation
# These are already set, but you can uncomment them if you want to change them
# or use as a model for other changes
docker compose run --rm wpcli option update siteurl "${WP_URL}"
docker compose run --rm wpcli option update home "${WP_URL}"

echo "✅ WordPress installation completed."

if [ "$INSTALL_PLUGINS" == "true" ] ; then
  echo "🚀 Installing plugins..."
  ./plugins_install.sh
else
  echo "🚫 Skipping plugin installation."
fi
echo "✅ Plugin installation completed."

# --- WooCommerce Setup ---
if [ "$CONFIGURE_WOOCOMMERCE" == "true" ] ; then
  echo "📦 Attempting to configure WooCommerce..."
  # Call the dedicated WooCommerce setup script
  # Make sure the path is correct relative to where setup.sh is run
  ./scripts/configure-woocommerce.sh
  WOO_SETUP_EXIT_CODE=$?
  if [ ${WOO_SETUP_EXIT_CODE} -ne 0 ]; then
    echo "❌ WooCommerce initial configuration failed. Aborting."
    exit ${WOO_SETUP_EXIT_CODE} # Propagate the error code
  fi
else
  echo "🚫 Skipping WooCommerce initial configuration."
fi