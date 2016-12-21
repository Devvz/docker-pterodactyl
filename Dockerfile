LABEL version="latest"

#We need to install PHP
RUN yum install php70-php php70-php-common php70-php-fpm php70-php-cli php70-php-mysql php70-php-mcrypt php70-php-gd php70-php-mbstring php70-php-pdo php70-php-zip php70-php-bcmath php70-php-dom php70-php-opcache \
 && ln -s /usr/bin/php70 /usr/bin/php \
 && ln -s /usr/bin/php70-phar /usr/bin/php-phar

#We have configuration files in a directory that need to be copied up
COPY ./locationatgithub/

#We need to specify the directory we want the following RUN commands to affect
WORKDIR /var/www/html/pterodactyl/

#THE FIRST COMMAND HERE SHOULD BE ONE OF THE FILES FROM THE COPIED DIRECTORY
#THIS FILE CONFIGURED THE PHP ARTISAN SETTINGS
RUN curl -Lo v0.5.5.tar.gz https://github.com/Pterodactyl/Panel/archive/v0.5.5.tar.gz \ #Download panel files
 && tar --strip-components=1 -xzvf v0.5.5.tar.gz \ #Unpack archive of files
 && rm v0.5.5.tar.gz \ #Remove panel files (after unpacking)
 && chmod -R 777 storage/* bootstrap/cache \ #Set correct permissions on files so panel can write logs and caches
 && chown -R www-data:www-data * \ #Set owner of the files
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \ #Install Composer
 && composer setup #Configure Composer





#ENVIRONMENT CONFIGURATION - THIS WILL BE GOING IN A SEPARATE FILE IN ANOTHER DIRECTORY THAT GETS COPIED UP
#Environment setup
php artisan pterodactyl:env

#Email handling
php artisan pterodactyl:mail

#Automatic database setup
php artisan migrate

#Seed database with service information
php artisan db:seed

#Create an admin account
php artisan pterodactyl:user





#QUEUE LISTENERS - I'M NOT EVEN SURE THIS IS NECESSARY...?
#Configure Crontab so server tasks are queued
crontab -e
* * * * * php /var/www/pterodactyl/html/artisan schedule:run >> /dev/null 2>&1

#Start the service
systemctl start cron

Install Supervisor to facilitate running and controlling of queues
yum install supervisor
systemctl start supervisor

#Create configuration file `pterodactyl-worker.conf` in the `/etc/supervisor/conf.d` directory
#Configure the following contents: 

[program:pterodactyl-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/pterodactyl/html/artisan queue:work database --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/pterodactyl/html/storage/logs/queue-worker.log

#Allow Supervisor to read configuration
supervisorctl reread
supervisorctl update

#Start worker
supervisorctl start pterodactyl-worker:*
systemctl enable supervisor
