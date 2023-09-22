#!/bin/bash

# Wait for MySQL to be ready
while ! mysqladmin ping -h"db" --silent; do
    sleep 1
done


# Check if WordPress files are present. If not, download and install them.
if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --locale=${LOCALE} --allow-root --path=/var/www/html
    wp config create --dbname=${MYSQL_DATABASE} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASSWORD} --dbhost=${MYSQL_HOST} --allow-root --path=/var/www/html
    wp core install --url=${VIRTUAL_HOST} --title="${SITE_TITLE}" --admin_user=${WP_USER} --admin_password=${WP_PASSWORD} --admin_email=${WP_EMAIL} --allow-root --path=/var/www/html
fi

# Wait for WordPress to start
while ! wp core is-installed --allow-root --path=/var/www/html; do
    echo "WP Core still not installed"
    sleep 5
done

echo "WP Core installed"

# Install and activate the theme
wp theme install $THEME_NAME --activate --allow-root --path=/var/www/html
echo "THEME defined"

# Deactivate and uninstall Akismet Anti-Spam
wp plugin deactivate akismet --allow-root --path=/var/www/html
wp plugin uninstall akismet --allow-root --path=/var/www/html

# Deactivate and uninstall Hello Dolly
wp plugin deactivate hello --allow-root --path=/var/www/html
wp plugin uninstall hello --allow-root --path=/var/www/html

# Install and activate plugins
IFS=',' read -ra PLUGIN_ARRAY <<< "$PLUGINS"
for plugin in "${PLUGIN_ARRAY[@]}"; do
    wp plugin install $plugin --activate --allow-root --path=/var/www/html
done
echo "Plugins defined"
