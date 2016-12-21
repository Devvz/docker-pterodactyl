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
- Install Composer `curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer`
- Configure Composer `composer setup`
- Environment setup `php artisan pterodactyl:env`
- Configure email handling `php artisan pterodactyl:mail`
- Automatic database setup `php artisan migrate`
- Seed database with service information `php artisan db:seed`
- Create an admin account `php artisan pterodactyl:user`
- Configure Crontab so server tasks are queued `crontab -e` `* * * * * php /var/www/pterodactyl/html/artisan schedule:run >> /dev/null 2>&1`
- Start the service `systemctl start cron`
- Install Supervisor to facilitate running and controlling of queues `apt-get install supervisor` `systemctl start supervisor`
- Create configuration file `pterodactyl-worker.conf` in the `/etc/supervisor/conf.d` directory
- Configure the following contents:

`[program:pterodactyl-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/pterodactyl/html/artisan queue:work database --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/pterodactyl/html/storage/logs/queue-worker.log`
- Allow Supervisor to read configuration `supervisorctl reread` `supervisorctl update`
- Start worker `supervisorctl start pterodactyl-worker:*` `systemctl enable supervisor`
- Enable public panel by adding a configuration file in `/etc/nginx/sites-available` called `pterodactyl.conf`
- Edit file:

`pterodactyl.conf` with settings `server {
    listen 80;
    server_name <domain>;
    root "/var/www/pterodactyl/html/public";
    index index.html index.htm index.php;
    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
- Symlink new configuration file into `sites-enabled` folder `ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf`
- Restart nginx service `systemctl restart nginx`
