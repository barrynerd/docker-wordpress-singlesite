#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Configuring WooCommerce initial settings..."

# Explicitly setting the 'woocommerce_onboarding_profile' option via WP-CLI.
# This ensures the option is set reliably as a post-installation step,
# complementing the mu-plugin's filters and preventing the wizard redirect
# on the first web request.
echo "🚀 Setting WooCommerce onboarding profile to skipped via WP-CLI..."

# Using --quiet to suppress the "Success" message and the potential "Error"
# if the option value is already the same.
docker compose run --rm wpcli option update woocommerce_onboarding_profile '{"skipped":true}' --format=json --autoload=no --quiet
ONBOARDING_EXIT_CODE=$?

# Check the exit code. If it's 0 (success) or if the option is already set,
# then it's a successful configuration.
if [ ${ONBOARDING_EXIT_CODE} -eq 0 ]; then
  echo "✅ WooCommerce onboarding profile set to skipped (via WP-CLI)."
# WP-CLI returns exit code 1 if no change was made, which is fine here.
# We'll check if the option actually contains the desired value.
elif docker compose run --rm wpcli option get woocommerce_onboarding_profile --format=json --quiet | grep -q '"skipped":true'; then
  echo "⚠️ WooCommerce onboarding profile was already skipped. No explicit update needed (via WP-CLI)."
  # Reset the exit code to 0 for the script's overall success check
  ONBOARDING_EXIT_CODE=0
else
  echo "❌ Failed to set WooCommerce onboarding profile. Exit code: ${ONBOARDING_EXIT_CODE}. Aborting."
  exit 1 # Exit with error if a genuine failure occurred
fi

# --- Future WooCommerce Configuration Goes Here ---
# This is where you would add commands to:
# 1. Update general WooCommerce store options (e.g., currency, store address).
# 2. Configure tax rates (potentially via CSV import or direct wp option update).
# 3. Set up default shipping zones or payment gateways.
# 4. Any other baseline WooCommerce settings you want to automate.

echo "✅ WooCommerce initial configuration completed."