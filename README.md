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

## Questions

1) Does Container1 (pterodb) and Container2 (pterophp) need a link so they can communicate with one another? We configured a link from Container3 (pteroweb) to the other two containers, but nothing to allow those two to communicate with one another.  
2) The `yum install openssl-devel` command from the installation instructions - where does this need to be executed?  
3) The database configuration where it specifies that I will create **an empty database** (https://docs.pterodactyl.io/docs/installing-1), is this local to the Pterodactyl container or is this utilizing mariadb?  
4) There are some additional settings for the NGINX installation that I need to clear up that I'm not sure how to apply. Some of them were applied with the old Dockerfile which combined the panel installation with the NGINX installation and some I wasn't able to find at all.  
- **Dockerfile RUN1** Need to make `/etc/nginx/sites-available/`
- Need to create `pterodactyl.conf` within `/etc/nginx/sites-available` to allow it to be publicly available and modify the config file above using https://docs.pterodactyl.io/docs/webserver-configuration. I added a config file to /manifest/etc/nginx/conf.d but I'm not quite sure what this means.
- Need to symlink new config file into sites-enabled `ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf`
- Need to restart nginx service `systemctl restart nginx`  
5) Is there anything else I need to do for Pterodactyl panel? For example, after I run composer setup?  
6) Are queue listeners necessary?
