#!/bin/bash

# CHECK FOR REQUIRED DEPENDENCIES
echo "Checking dependencies..."
hash mysql 2>/dev/null || { echo >&2 "Can't find mysql. Make sure it is in you PATH. Aborting."; exit 1; }
echo "mysql found. OK!"
hash wp 2>/dev/null || { echo >&2 "I need wp-cli to function. Please install it first. Aborting."; exit 1; }
echo "wp found. OK!"
hash git 2>/dev/null || { echo >&2 "I need git to function. Please install it first. Aborting."; exit 1; }
echo "git found. OK!"
echo

# Remove the origin, because we don't want it
git remote remove origin

# Just in case, remove composer.lock
rm composer.lock

# Install all the base stuff like WordPress and such
echo "Running composer..."
composer install

# Copy the languages directory ( if it exists )
if [ -f web/wp/wp-content/languages ]; then
	echo "Copying languages to app directory..."
	cp -r web/wp/wp-content/languages web/app/languages
fi

echo
echo "WordPress files are installed!"
echo

echo -n "Enter the Database name: "
read db_name
echo

echo -n "Enter the Database user: (root) "
read db_user
echo

echo -n "Enter the Database password: (root) "
read db_password
echo

echo -n "Enter the Database host: (localhost) "
read db_host
echo

echo -n "Enter the domain of this site, eg. example.dev: "
read wp_home
echo

# Set default values if inputs were empty
if [ -z "$db_user" ]; then
	db_user="root"
fi

if [ -z "$db_password" ]; then
	db_password="root"
fi

if [ -z "$db_host" ]; then
	db_host="localhost"
fi

# CREATE DATABASE
echo "Creating database $db_name..."
sql="create database $db_name;"
mysql --user=$db_user --password=$db_password <<< ${sql}


echo "Creating .env file..."

cp .env.example .env

sed -i -e "s/database_name/$db_name/g" .env
sed -i -e "s/database_user/$db_user/g" .env
sed -i -e "s/database_password/$db_password/g" .env
sed -i -e "s/database_host/$db_host/g" .env

sed -i -e "s/example.com/$wp_home/g" .env

rm .env-e

echo "Configuration file created, ready for installation"
echo

echo -n "Enter the title for this site: "
read site_title
echo

echo -n "Enter the admin username: (h1admin) "
read admin_user
echo

echo -n "Enter the admin password: (leave empty to generate) "
read admin_password
echo

echo -n "Enter the admin email: (admin@h1.fi) "
read admin_email
echo

if [ -z "$admin_user" ]; then
	admin_user="h1admin"
fi

if [ -z "$admin_password" ]; then
	# CREATE A UNIQUE PASSWORD
	admin_password=$(openssl rand -base64 10)
fi

if [ -z "$admin_email" ]; then
	admin_email="admin@h1.fi"
fi

echo "OK. I now have this information: "
echo "User: $admin_user"
echo "Admin email: $admin_email"
echo "Pass: $admin_password"
echo "Site address: $wp_home"
echo "Site title: $site_title"
echo

read -p "If the above is OK, press [Enter] key to install WordPress..."

echo
echo "Installing WordPress..."

wp core install --url="http://$wp_home" --title="$site_title" --admin_user="$admin_user" --admin_password="$admin_password" --admin_email="$admin_email"

#
echo
read -p "Do you want to install the H1 Theme and Feature plugins?:  " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    git clone --depth=1 https://github.com/H1FI/h1-theme.git web/app/themes/h1-theme
    git clone --depth=1 https://github.com/H1FI/h1-project-features.git web/app/plugins/h1-project-features
    
    rm -rf web/app/themes/h1-theme/.git
    rm -rf web/app/plugins/h1-project-features/.git
fi

if [  ]

cd web/app/themes/


echo
echo "------------------------------------------------------------"
echo " All done! Remember to create a virtual host $wp_home       "
echo " and point it to the web/ subfolder in this project.        "
echo "                                                            "
echo " User: $admin_user                                          "
echo " Pass: $admin_password                                      "
echo "------------------------------------------------------------"
echo