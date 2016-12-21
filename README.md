## Pterodactyl Panel Docker Container
This container is built to run the Pterodactyl server management panel. It includes the panel itself as well as the necessary PHP dependencies. It does not include the other components required for the panel to function (NGINX and MariaDB). However, the following instructions will walk you through configuring these in their own individual containers.

This container was built using CentOS 7.1 with PHP7.

## Running the Container using `docker-compose`

Using the `docker-compose` feature will automatically deploy all of the necessary attributes contained within this file. If you would prefer to do this manually, please move onto the next section.

Pull the container:

`docker pull quay.io/linkgoeshere`  

Run the containers:

`docker-compose -d`  

## Running the Container Manually

The container requires a database. MariaDB is the recommended database.

The following command creates another container using the MariaDB image. It also configures the necessary database (environment) settings, hence the numerous -e flags:

`docker run -it --name pterodb -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=pterodb -e MYSQL_USER=pterodactyl -e MYSQL_PASSWORD=pterodactylpassword --name pterodb -d mariadb`

The following command creates the Pterodactyl panel container and exposes port 80 and 443 externally and internally. It also links the Pterodactyl container to the database container which is required for communication. It also configures numerous settings for the container:

`docker run -it -p 80:80 -p 443:443 -v /srv/pterodactyl/.env:/var/www/html/.env --link pterodb -e db_host=pterodb -e db_port=3306 -e db_name=pterodb -e db_user=ptero -e db_pass=pterodactylpassword -e panel_url= -e timezone="America/New_York" -e email_driver=mail -e panel_email=foo@bar.org --name pteroweb quay.io/linkgoeshere:latest`

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
