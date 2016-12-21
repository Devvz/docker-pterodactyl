## Pterodactyl Docker Containers
This installation was designed to configure Pterodactyl using three separate Docker containers each individually running a service required for the panel to function properly. These containers were built with CentOS 7.1 using PHP7.

## Configuring the Containers

**Database Container (pterodb)**

The container requires a database. MariaDB is the recommended database.

The following command creates a container using the MariaDB image. It also configures the necessary environment settings for the database to function properly:

`docker run -it --name pterodb -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=pterodb -e MYSQL_USER=pterodactyl -e MYSQL_PASSWORD=pterodactylpassword --name pterodb -d mariadb`

**Pterodactyl Container (pterophp)**

The following command creates the Pterodactyl panel container. It exposes port 9000 externally and internally which is required to allow this container to communicate with the web server container.

`docker run -it --expose 9000:9000 --name pterophp quay.io/linkgoeshere:latest`

**Website Container (pteroweb)**

The container requires a web server. NGINX is the recommended web server.

The following command creates a container using the NGINX image. It exposes port 80 and 443 externally and internally. It also links the containers to one another which is required for communication. It also configures the necessary environment settings for the web server to function properly:

`docker run -it -p 80:80 -p 443:443 -v /srv/pterodactyl/.env:/var/www/html/.env --link pterophp --link pterodb -e db_host=pterodb -e db_port=3306 -e db_name=pterodb -e db_user=ptero -e db_pass=pterodactylpassword -e panel_url= -e timezone="America/New_York" -e email_driver=mail -e panel_email=foo@bar.org --name pteroweb quay.io/linkgoeshere:latest`

## Additional Settings

The full list of supported environment flags are:

**Database Settings**

db_host="hostname"  
db_port="port"  
db_name="database name"  
db_user="username"  
db_pass="database password"  
panel_url="panel url"  
timezone="panel timezone in php time"

**Email Settings**

email_driver="email driver"  
panel_email="email address for the panel"  
email_user="email username"  
email_pass="email password"  
email_domain="email domain"  
email_port="email port" 

Only the driver and email address are required for the "mail" driver.  
driver, email, and username(api key) are used for "mandrill" and "postmark".  
driver, email, username(api key), and domain are required for "mailgun". All settings are required for "smtp"  

**Administrator Setup**

admin_email="admin email"  
admin_pass="admin password"  
admin_stat=1 (should stay 1 to set user as admin)
