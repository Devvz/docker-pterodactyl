# Pterodactyl Docker Containers
This installation was designed to configure Pterodactyl using three separate Docker containers each individually running one of the major services required for the panel to function properly. These containers were built with CentOS 7.1 using PHP7.

## Configuring the Containers

**Database Container (pterodb)**

Pterodactyl requires a database. MariaDB is the recommended database.

The following command creates a container using the MariaDB image. It also configures the necessary environment settings for the database to function properly:

`docker run -it --name pterodb -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=pterodb -e MYSQL_USER=pterodactyl -e MYSQL_PASSWORD=pterodactylpassword --name pterodb -d mariadb`

**Pterodactyl Container (pterophp)**

The following command creates the Pterodactyl panel container. It exposes port 9000 externally and internally which is required to allow this container to communicate with the web server container.

`docker run -it -p 9000:9000 --name pterophp quay.io/linkgoeshere:latest`

**Website Container (pteroweb)**

Pterodactyl requires a web server. NGINX is the recommended web server.

The following command creates a container using the NGINX image. It exposes port 80 and 443 externally and internally. It also links the containers to one another which is required for communication. It also configures the necessary environment settings for the web server to function properly:

`docker run -it -p 80:80 -p 443:443 -v /srv/pterodactyl/.env:/var/www/html/.env --link pterophp --link pterodb -e db_host=pterodb -e db_port=3306 -e db_name=pterodb -e db_user=ptero -e db_pass=pterodactylpassword -e panel_url= -e timezone="America/New_York" -e email_driver=mail -e panel_email=foo@bar.org--name pteroweb nginx`

## Questions

1) Does Container1 (pterodb) and Container2 (pterophp) need a link so they can communicate with one another? We configured a link from Container3 (pteroweb) to the other two containers, but nothing to allow those two to communicate with one another.  
2) We're supposed to be changing directory to /var/www/pterodactyl/html as this is where the panel itself is to be installed. Is this still relevant somewhere here?  
2) The `yum install openssl-devel` command from the installation instructions - where does this need to be executed?

## Outstanding Tasks

1) Need to create the quay.io docker file.  
2) Need to import docker file to quay.io in order to configure image.
- PHP install `yum install php70-php php70-php-common php70-php-fpm php70-php-cli php70-php-mysql php70-php-mcrypt php70-php-gd php70-php-mbstring php70-php-pdo php70-php-zip php70-php-bcmath php70-php-dom php70-php-opcache` `ln -s /usr/bin/php70 /usr/bin/php` `ln -s /usr/bin/php70-phar /usr/bin/php-phar`
- Download panel files `curl -Lo v0.5.5.tar.gz https://github.com/Pterodactyl/Panel/archive/v0.5.5.tar.gz`
- Unpack archive of files `tar --strip-components=1 -xzvf v0.5.5.tar.gz`
- Set correct permissions on files so panel can write logs and caches `chmod -R 777 storage/* bootstrap/cache`
- Set owner of the files `chown -R www-data:www-data *`
