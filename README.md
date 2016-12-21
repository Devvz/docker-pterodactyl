# Pterodactyl Docker Containers
This installation was designed to configure Pterodactyl using three separate Docker containers each individually running one of the major services required for the panel to function properly:

- The Pterodactyl panel (PHP)  
- MySQL (mariadb)  
- Web server (NGINX)

These containers were built with CentOS 7.1 using PHP7.

## Configuring the Containers

**Database Container (pterodb)**

Pterodactyl requires a database. MariaDB is the recommended database.

The following command creates a container using the MariaDB image. It also configures the necessary environment settings for the database to function properly:

`docker run -it --name pterodb -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=pterodb -e MYSQL_USER=pterodactyl -e MYSQL_PASSWORD=pterodactylpassword --name pterodb -d mariadb`

**Pterodactyl Container (pterophp)**

The following command creates the Pterodactyl panel container. It exposes port 9000 externally and internally which is required to allow this container to communicate with the web server container.

`docker run -it -p 9000:9000 --name pterophp quay.io/xyeLz/link:version`

See "dockerfile" for Dockerfile information.

**Website Container (pteroweb)**

Pterodactyl requires a web server. NGINX is the recommended web server.

The following command creates a container using the NGINX image. It exposes port 80 and 443 externally and internally. It also links the containers to one another which is required for communication. It also configures the necessary environment settings for the web server to function properly:

`docker run -it -p 80:80 -p 443:443 -v /srv/pterodactyl/.env:/var/www/html/pterodactyl/.env --link pterophp --link pterodb -e db_host=pterodb -e db_port=3306 -e db_name=pterodb -e db_user=ptero -e db_pass=pterodactylpassword -e panel_url= -e timezone="America/New_York" -e email_driver=mail -e panel_email=foo@bar.org --name pteroweb nginx`

- **Dockerfile WORKDIR** `/var/www/html/pterodactyl`
- **Dockerfile RUN1** Need to make `/etc/nginx/sites-available/`
- Need to create `pterodactyl.conf` within `/etc/nginx/sites-available` to allow it to be publicly available
- Need to modify the config file above using https://docs.pterodactyl.io/docs/webserver-configuration
- Need to symlink new config file into sites-enabled `ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf`
- Need to restart nginx service `systemctl restart nginx`

## Questions

1) Does Container1 (pterodb) and Container2 (pterophp) need a link so they can communicate with one another? We configured a link from Container3 (pteroweb) to the other two containers, but nothing to allow those two to communicate with one another.  
2) We're supposed to be changing directory to /var/www/pterodactyl/html as this is where the panel itself is to be installed. Do I need to reference this directory somewhere (either in the Dockerfile or the image)?
2) The `yum install openssl-devel` command from the installation instructions - where does this need to be executed?
