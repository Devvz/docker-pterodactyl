LABEL version="latest"

RUN 

#Install PHP
yum install php70-php php70-php-common php70-php-fpm php70-php-cli php70-php-mysql php70-php-mcrypt php70-php-gd php70-php-mbstring php70-php-pdo php70-php-zip php70-php-bcmath php70-php-dom php70-php-opcache 
ln -s /usr/bin/php70 /usr/bin/php
ln -s /usr/bin/php70-phar /usr/bin/php-phar

WORKDIR /var/www/html/pterodactyl

RUN

#Download panel files
curl -Lo v0.5.5.tar.gz https://github.com/Pterodactyl/Panel/archive/v0.5.5.tar.gz

#Unpack archive of files
tar --strip-components=1 -xzvf v0.5.5.tar.gz

#Remove panel files (after unpacking)
rm v0.5.5.tar.gz

#Set correct permissions on files so panel can write logs and caches
chmod -R 777 storage/* bootstrap/cache

#Set owner of the files
chown -R www-data:www-data *

#Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Configure Composer
composer setup

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
