# Pterodactyl Docker Containers
This installation was designed to configure Pterodactyl using three separate Docker containers each individually running one of the major services required for the panel to function properly:

- Pterodactyl (PHP)  
- MySQL (MariaDB)  
- Web Server (NGINX)

These containers were built with CentOS 7.1 using PHP7.

## Configuring the Containers

**Database Container (pterodb)**

Pterodactyl requires a database. MariaDB is the recommended database.

The following command creates a container using the MariaDB image. It also configures the necessary environment settings for the database to function properly:

`docker run -it -p 3306:3306 -v /srv/pterodactyl/database:/var/lib/mysql --name pterodb -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=pterodb -e MYSQL_USER=pterodactyl -e MYSQL_PASSWORD=pterodactylpassword --name pterodb -d mariadb`

**Pterodactyl Container (pterophp)**

The following command creates the Pterodactyl panel container. It exposes port 9000 externally and internally which is required to allow this container to communicate with the web server container.

`docker run -it -p 9000:9000 --name pterophp quay.io/xyeLz/link:version`

See "dockerfile" for Dockerfile information.

**Website Container (pteroweb)**

Pterodactyl requires a web server. NGINX is the recommended web server.

The following command creates a container using the NGINX image. It exposes port 80 and 443 externally and internally. It also links the containers to one another which is required for communication. It also configures the necessary environment settings for the web server to function properly:

`docker run -it -p 80:80 -p 443:443 -v /srv/pterodactyl/.env:/var/www/html/pterodactyl/.env --link pterophp --link pterodb -e db_host=pterodb -e db_port=3306 -e db_name=pterodb -e db_user=ptero -e db_pass=pterodactylpassword -e panel_url= -e timezone="America/New_York" -e email_driver=mail -e panel_email=foo@bar.org --name pteroweb nginx`

## Questions

1) Does Container1 (pterodb) and Container2 (pterophp) need a link so they can communicate with one another? We configured a link from Container3 (pteroweb) to the other two containers, but nothing to allow those two to communicate with one another.  
2) The `yum install openssl-devel` command from the installation instructions - where does this need to be executed?  
3) There are additional settings for the NGINX installation that need to be configued *without* using a Dockerfile. I'm not sure how to go about this. I would like to *avoid* using a Dockerfile for these settings if possible.  
- Need to create the `/etc/nginx/sites-available/` directory (originally part of the first Dockerfile run command)  
- Need to create `pterodactyl.conf` within `/etc/nginx/sites-available` to allow the web interface to be publicly available and modify the config file above using https://docs.pterodactyl.io/docs/webserver-configuration. I added a config file to /manifest/etc/nginx/conf.d but I'm not quite sure how to reference this file without using a Dockerfile (or even with using one).
- Need to symlink new config file into sites-enabled `ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf`
- Need to restart nginx service `systemctl restart nginx`  
- Need to run `&& chown -R www-data:www-data * \` to grant ownership of the files.  
4) How does the Dockerfile know where to pull the configuration files? For example, it uses an entrypoint.sh file but the exact location of this file is never specified.  
5) Need to determine how to pull the PHP configuration (optional) for the Pterodactyl Dockerfile.  
