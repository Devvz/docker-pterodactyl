# Pterodactyl Docker Containers
This installation was designed to configure Pterodactyl using three separate Docker containers each individually running one of the major services required for the panel to function properly:

- MySQL (MariaDB)  
- Pterodactyl (PHP)  
- Web Server (NGINX)

These containers were built with CentOS 7.1 using PHP7.

## Overview

- Pterodactyl/PHP image needs to be created (Dockerfile)
- PHP needs to be installed (Dockerfile)
- Required files need to be uploaded to the image (Dockerfile)
* pterodactyl.conf
- The directory needs to change to where Pterodactyl is installed (Dockerfile)
- Pterodactyl panel dependencies need to be installed (Dockerfile)
- Composer needs to be installed (Dockerfile)


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

