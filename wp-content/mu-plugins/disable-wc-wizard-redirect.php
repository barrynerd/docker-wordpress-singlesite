<?php
/**
 * Plugin Name: Disable WooCommerce Setup Wizard Redirect
 * Description: Prevents WooCommerce from automatically redirecting to the setup wizard.
 * Version: 1.0
 * Author: Your Name
 */

error_log('*** DEBUG: disable-wc-wizard-redirect.php MU-plugin loaded and filters applied! ***');

# This is the primary filter to prevent the automatic redirection to the setup wizard.
add_filter( 'woocommerce_prevent_automatic_wizard_redirect', '__return_true' );

# These additional filters further disable WooCommerce Admin features and the setup wizard itself.
# They complement the primary redirect prevention.
add_filter( 'woocommerce_admin_disabled', '__return_true' );
add_filter( 'woocommerce_enable_setup_wizard', '__return_false' );
