# Pterodactyl Docker Containers
This installation was designed to configure Pterodactyl using three separate Docker containers each individually running one of the major services required for the panel to function properly:

- Pterodactyl (PHP)  
- MySQL (MariaDB)  
- Web Server (NGINX)

These containers were built with CentOS 7.1 using PHP7.

## Configuring the Containers

### Database Container (pterodb)

Pterodactyl requires a database. MariaDB is the recommended database.

**Docker Compose Installation**

### Pterodactyl Container (pterophp)

**Docker Compose Installation**

### Website Container (pteroweb)

Pterodactyl requires a web server. NGINX is the recommended web server.

**Docker Compose Installation**

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
