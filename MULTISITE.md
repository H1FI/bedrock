1. Add WP_ALLOW_MULTISITE to config/application.php
2. Start the multisite install process in the admin normally.
3. Copy the generated .htaccess values into your htaccess files
4. Add the required multisite constants to development.php, staging.php or production.php, taking care to remove references to subdirectories. At least DOMAIN_CURRENT_SITE should probably be defined as an environment variable in your .env file.
5. Check the home and siteurl values in wp_options and wp_sitemeta, removing any reference to subdirectories (yoursite.com/wp should be changed to yoursite.com). This is because the .htaccess rules take care of hiding the /wp in URL's.
6. Login to your site at yoursite.com/wp-login.php (NOT yoursite.com/wp/wp-login.php)
