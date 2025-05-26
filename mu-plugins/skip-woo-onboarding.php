<?php

/**
 * Plugin Name: Disable WooCommerce Setup Wizard Redirect
 * Description: Prevents WooCommerce from automatically redirecting to the setup wizard.
 * Version: 1.0
 * Author: Your Name
 */


error_log('*** DEBUG: disable-wc-wizard-redirect.php MU-plugin loaded! ***');
if (class_exists('WooCommerce')){
    # This is the primary filter to prevent the automatic redirection to the setup wizard.
    add_filter('woocommerce_prevent_automatic_wizard_redirect', '__return_true');

    # These additional filters further disable WooCommerce Admin features and the setup wizard itself.
    # They complement the primary redirect prevention.
    add_filter('woocommerce_admin_disabled', '__return_true');
    add_filter('woocommerce_enable_setup_wizard', '__return_false');
}
/**
 * Directly update the woocommerce_onboarding_profile option to skip the wizard.
 * This is crucial if the wizard checks DB state before or regardless of filters.
 */
function my_custom_skip_woo_onboarding()
{
    $wc_option       = 'woocommerce_onboarding_profile';
    $skip_onboarding = array(
        'skipped' => true,
    );
    $profile         = (array) get_option($wc_option, array());

    // Only update if 'skipped' is not already true to avoid unnecessary DB writes
    if (!isset($profile['skipped']) || $profile['skipped'] !== true) {
        update_option($wc_option, array_merge($profile, $skip_onboarding));
        error_log('*** DEBUG: woocommerce_onboarding_profile option set to skipped! ***');
    } else {
        error_log('*** DEBUG: woocommerce_onboarding_profile already skipped. ***');
    }
}

# Hook the function to run as early as possible after plugins are loaded.
# Priority 1 is very early.
// add_action('plugins_loaded', 'my_custom_skip_woo_onboarding', 1);
