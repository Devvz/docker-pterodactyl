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
- Creates web container using NGINX and copies correct configuration file (/etc/nginx/sites-available/pterodactyl.conf)
- Creates Pterodactyl container by pulling image we created in the Dockerfile from Quay.io (based on PHP)
- Configures Pterodactyl container environment variables (db_env)
- Creates database container using MariaDB
- Configures database container environment variables (MYSQL_env)

**Create**

- Build the image  
`docker build -t pterodactyl-standalone .` The location for pterodactyl-standalone is specified in the Dockerfile  
`docker-compose up` This reads the docker-compose.yml file which contains the image location on Quay.io, and then performs the operations within the yml file (creation of containers)

**Missing Steps**

- Run the following commands during the PHP installation (Dockerfile):  
`ln -s /usr/bin/php70 /usr/bin/php`  
`ln -s /usr/bin/php70-phar /usr/bin/php-phar`  
- Run the following commands during the Pterodactyl installation (Docker Compose):  
`chmod -R 777 storage/* bootstrap/cache`  
`chown -R www-data:www-data *`  
- Perform the `composer setup` command (or is this what the `composer install` command is for?) (Dockerfile)  
- Environment configuration:  
`php artisan pterodactyl:env`  
`php artisan pterodactyl:mail`  
`php artisan migrate`  
`php artisan db:seed`  
`php artisan pterodactyl:user`  
- Queue listeners (Crontab):  
`crontab -e`  
`* * * * * php /var/www/pterodactyl/html/artisan schedule:run >> /dev/null 2>&1`  
- Queue listeners (Supervisor):  
`apt-get install supervisor`  
`service supervisor start`  
- Queue listeners (Configuration File):  
`pterodactyl-worker.conf` in `/etc/supervisor/conf.d` directory  

`[program:pterodactyl-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/pterodactyl/html/artisan queue:work database --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/pterodactyl/html/storage/logs/queue-worker.log`  

- Queue listeners (Update Supervisor):  
`supervisorctl reread`  
`supervisorctl update`  
- Queue listeners (Start Worker Queue):  
`supervisorctl start pterodactyl-worker:*`  
`systemctl enable supervisor`  
- During Docker Compose, do we need to run the following to symlink the new configuration file into the sites-enabled folder?  
`ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf`  
`systemctl restart nginx`

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

