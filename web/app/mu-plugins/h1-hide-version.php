<?php
/**
 * Hides the WP generator from wp_head
 */
function h1_remove_version() {
    return '';
}
add_filter('the_generator', 'h1_remove_version');