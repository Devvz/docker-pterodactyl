# Pterodactyl Docker Containers
This installation was designed to configure Pterodactyl using three separate Docker containers each individually running one of the major services required for the panel to function properly:

- MySQL (MariaDB)  
- Pterodactyl (PHP)  
- Web Server (NGINX)

These containers were built with CentOS 7.1 using PHP7.

## Overview

**Dockerfile (configures Pterodactyl/PHP image)**
- Installs PHP on image
- Uploads required files on image (`/etc/nginx/sites-available/pterodactyl.conf` for PHP)
- Changes directory to Pterodactyl (`/var/www/html/pterodactyl`)
- Extracts Pterodactyl files to current directory on image (for panel installation)
- Installs Composer on image

**docker-compose.yml (creates containers for all services)**
- Creates web container using NGINX
- Configures NGINX by copying configuration file (`/etc/nginx/sites-available/pterodactyl.conf`)
- Creates Pterodactyl container by pulling image we created in the Dockerfile from Quay.io (based on PHP)
- Configures Pterodactyl container environment variables (db_env) and copies over queue listener configuration file (`/etc/supervisor/conf.d/pterodactyl-worker.conf`)
- Creates database container using MariaDB
- Configures database container environment variables (MYSQL_env)

**Missing Steps**

- Run the following commands during the PHP installation (Dockerfile):  
`ln -s /usr/bin/php70 /usr/bin/php`  
`ln -s /usr/bin/php70-phar /usr/bin/php-phar`  
- Run the following commands during the Pterodactyl installation (Docker Compose):  
`chmod -R 777 storage/* bootstrap/cache`  
`chown -R www-data:www-data *`  
- ~~Perform the `composer setup` command (Dockerfile)~~  
~~*Log: We are already doing this using the `composer install --ansi --no-dev` command. This is the same command executed in a different way.*~~
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
- ~~Queue listeners (Configuration File):~~  
~~`pterodactyl-worker.conf` in `/etc/supervisor/conf.d` directory~~  
~~`[program:pterodactyl-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/pterodactyl/html/artisan queue:work database --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/pterodactyl/html/storage/logs/queue-worker.log`~~  
~~*Log: Added `- ./files/etc/supervisor/conf.d/pterodactyl-worker.conf/:/etc/supervisor/conf.d/pterodactyl-worker.conf` to docker-composer.yml*~~  

- Queue listeners (Update Supervisor):  
`supervisorctl reread`  
`supervisorctl update`  
- Queue listeners (Start Worker Queue):  
`supervisorctl start pterodactyl-worker:*`  
`systemctl enable supervisor`  
- In the docker-compose.yml, do we need to run the following to symlink the new configuration file into the sites-enabled folder?  
`ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf`  
`systemctl restart nginx`

## Deploy

- Move docker-compose.yml to a local directory  
`???`  
- Deploy the containers  
`docker-compose up` This reads the docker-compose.yml file which pulls the image location from Quay.io and then performs the operations within the yml file (creation of containers)

## Questions

- If we're already copying files in the Dockerfile, why do we need to also perform the same command in the docker-compose.yml for the volumes?
- The specified volume locations, what do they mean?
