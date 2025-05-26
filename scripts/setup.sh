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
if [ "$INSTALL_WOOCOMMERCE" == "true" ] ; then
  echo "🚀 Configuring WooCommerce initial settings..."

  # IMPORTANT: Configure WooCommerce after it's installed and activated.
  echo "🚀 Configuring WooCommerce onboarding profile..."
  WOO_ONBOARDING_PROFILE_JSON='{"skipped":true}'
  docker compose run --rm wpcli option update woocommerce_onboarding_profile "$WOO_ONBOARDING_PROFILE_JSON" --format=json --autoload=no
  ONBOARDING_EXIT_CODE=$?
  if [ ${ONBOARDING_EXIT_CODE} -eq 0 ]; then
    echo "✅ WooCommerce onboarding profile set to skipped."
  else
    echo "❌ Failed to set WooCommerce onboarding profile. Exit code: ${ONBOARDING_EXIT_CODE}."
  fi


# # ---
# ## 1. Create a Must-Use Plugin to prevent WooCommerce setup wizard redirect
# echo "📄 Attempting to create mu-plugin directory and file..."

# MU_PLUGINS_DIR="./wp-content/mu-plugins"
# TARGET_PATH="/var/www/html/wp-content" # Absolute path for checking permissions

# echo "DEBUG: Checking existence and permissions of /var/www/html/wp-content/ before mkdir:"
# # Execute 'ls' directly in the container's bash shell
# docker compose run --user 33:33 --rm --entrypoint bash wpcli -c "ls -ld ${TARGET_PATH}" || echo "Could not check ${TARGET_PATH}"


#   echo "DEBUG: Running mkdir -p ${MU_PLUGINS_DIR} inside wpcli container..."
#   # Execute 'mkdir' directly in the container's bash shell
#   docker compose run --user 33:33 --rm --entrypoint bash wpcli -c "mkdir -p ${MU_PLUGINS_DIR}"
#   MKDIR_EXIT_CODE=$?
#   if [ ${MKDIR_EXIT_CODE} -ne 0 ]; then
#     echo "ERROR: mkdir failed for ${MU_PLUGINS_DIR}. Exit code: ${MKDIR_EXIT_CODE}. Exiting setup script."
#     exit 1
#   fi
#   echo "DEBUG: mkdir command executed with exit code: ${MKDIR_EXIT_CODE}"

#   echo "DEBUG: Checking existence and permissions of /var/www/html/wp-content/mu-plugins/ after mkdir:"
#   # Execute 'ls' directly in the container's bash shell
#   docker compose run --user 33:33 --rm --entrypoint bash wpcli -c "ls -ld ${MU_PLUGINS_DIR}" || echo "Directory ${MU_PLUGINS_DIR} not found after mkdir attempt."

#   # Proceed with creating the plugin file only if mkdir was successful (exit code 0)
#   if [ ${MKDIR_EXIT_CODE} -eq 0 ]; then
#     MU_PLUGIN_FILE_IN_CONTAINER="./wp-content/mu-plugins/disable-wc-wizard-redirect.php" # Path relative to /var/www/html

#     # Use a nested here-document for the cat command executed inside the container
#     docker compose run --user 33:33 --rm --entrypoint bash wpcli -c "cat <<'EOF_INNER_MUPLUGIN' > '${MU_PLUGIN_FILE_IN_CONTAINER}'
# <?php
# /**
#  * Plugin Name: Disable WooCommerce Setup Wizard Redirect
#  * Description: Prevents WooCommerce from automatically redirecting to the setup wizard.
#  * Version: 1.0
#  * Author: Your Name
#  */

# error_log('*** DEBUG: disable-wc-wizard-redirect.php MU-plugin loaded! ***');

# # This is the primary filter to prevent the automatic redirection to the setup wizard.
# add_filter( 'woocommerce_prevent_automatic_wizard_redirect', '__return_true' );

# # These additional filters further disable WooCommerce Admin features and the setup wizard itself.
# # They complement the primary redirect prevention.
# add_filter( 'woocommerce_admin_disabled', '__return_true' );
# add_filter( 'woocommerce_enable_setup_wizard', '__return_false' );

# /**
#  * Directly update the woocommerce_onboarding_profile option to skip the wizard.
#  * This is crucial if the wizard checks DB state before or regardless of filters.
#  */
# function my_custom_skip_woo_onboarding() {
#     \$wc_option       = 'woocommerce_onboarding_profile';
#     \$skip_onboarding = array(
#         'skipped' => true,
#     );
#     \$profile         = (array) get_option( \$wc_option, array() );

#     // Only update if 'skipped' is not already true to avoid unnecessary DB writes
#     if ( !isset(\$profile['skipped']) || \$profile['skipped'] !== true ) {
#         update_option( \$wc_option, array_merge( \$profile, \$skip_onboarding ) );
#         error_log('*** DEBUG: woocommerce_onboarding_profile option set to skipped! ***');
#     } else {
#         error_log('*** DEBUG: woocommerce_onboarding_profile already skipped. ***');
#     }
# }

# # Hook the function to run as early as possible after plugins are loaded.
# # Priority 1 is very early.
# add_action( 'plugins_loaded', 'my_custom_skip_woo_onboarding', 1 );
# EOF_INNER_MUPLUGIN
# " # This closing quote is for the -c argument to bash
#     CAT_EXIT_CODE=$?
#     if [ ${CAT_EXIT_CODE} -eq 0 ]; then
#       echo "✅ Mu-plugin created at ${MU_PLUGIN_FILE_IN_CONTAINER}."
#     else
#       echo "❌ Failed to create mu-plugin file via cat. Exit code: ${CAT_EXIT_CODE}."
#     fi
#   else
#     echo "❌ Mu-plugin file not created due to previous mkdir failure."
#   fi

  echo "✅ WooCommerce initial configuration completed."
else
  echo "🚫 Skipping WooCommerce initial configuration."
fi