# Pterodactyl Docker Containers
This installation was designed to configure Pterodactyl using three separate Docker containers each individually running one of the major services required for the panel to function properly:

- MySQL (MariaDB)  
- Pterodactyl (PHP)  
- Web Server (NGINX)

These containers were built with CentOS 7.1 using PHP7.

## Overview

**Dockerfile (creates Pterodactyl/PHP image)**
- Installs PHP
- Uploads required files (/etc/nginx/sites-available/pterodactyl.conf for PHP)
- Changes directory to Pterodactyl (/var/www/html/pterodactyl)
- Extracts Pterodactyl files to current directory
- Installs Composer

**Docker Compose (creates containers for all services)**
- Creates web container using NGINX
- Creates Pterodactyl container using the image we created in the Dockerfile (based on PHP)
- Configures Pterodactyl container environment variables (db_x)
- Creates database container using MariaDB
- Configures database container environment variables (MYSQL_x)

**Missing Steps**

- Run the following commands during the PHP installation:  
`ln -s /usr/bin/php70 /usr/bin/php  
ln -s /usr/bin/php70-phar /usr/bin/php-phar`

## Configuring the Containers

### Database Container (MariaDB)

Pterodactyl requires a database. MariaDB is the recommended database.

**Docker Compose Installation**

### Pterodactyl Container (PHP)

**Docker Compose Installation**

### Website Container (NGINX)

Pterodactyl requires a web server. NGINX is the recommended web server.

**Docker Compose Installation**

## Questions

