FROM centos:7

MAINTAINER Michael Ferullo, <michael.j.ferullo@xyeLz.com>

#We need to enable the repository (Remi or IUS) and install PHP
RUN yum install -y epel-release http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
 && yum --enablerepo=remi install -y php70-php php70-php-common php70-php-fpm php70-php-cli php70-php-mysql php70-php-mcrypt php70-php-gd php70-php-mbstring php70-php-pdo php70-php-zip php70-php-bcmath php70-php-dom php70-php-opcache \
 && ln -s /usr/bin/php70 /usr/bin/php \
 && ln -s /usr/bin/php70-phar /usr/bin/php-phar
 && sed -i -e 's,;daemonize = yes,daemonize = no,g' /etc/php70/php-fpm.conf
 #We need something right here that specifies where the php config will be coming from (optional)

#We have configuration files in a directory that need to be copied up
COPY ./manifest/ /

#We need to specify the directory we want the following RUN commands to affect
WORKDIR /var/www/html/pterodactyl/

#We first specify the directory of the PHP settings which pull from the docker run command in the instructions to configure the environment settings
RUN chmod +x /var/www/html/pterodactyl/entrypoint.sh \
 && curl -Lo v0.5.5.tar.gz https://github.com/Pterodactyl/Panel/archive/v0.5.5.tar.gz \
 && tar --strip-components=1 -xzvf v0.5.5.tar.gz \
 && rm v0.5.5.tar.gz \
 && chmod -R 777 storage/* bootstrap/cache \
 && chown -R nginx:nginx * \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && composer setup

#Set correct permissions on files so panel can read php artisan settings *is this correct?*
#Download panel files
#Unpack archive of files
#Remove panel files (after unpacking)
#Set correct permissions on files so panel can write logs and caches
#Set owner of the files
#Install Composer
#Configure Composer

ENTRYPOINT ["/var/www/html/pterodactyl/entrypoint.sh"]


#QUEUE LISTENERS
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
