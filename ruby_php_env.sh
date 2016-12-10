# php
sudo apt-get install software-properties-common python-software-properties -y
sudo add-apt-repository ppa:ondrej/php (help http://stackoverflow.com/questions/36788873/package-php5-have-no-installation-candidate-ubuntu-16-04)
sudo apt-get update
sudo apt-get install php5.6 -y
sudo apt-get install php5.6-cli php5.6-common php5.6-mysql php5.6-gd php5.6-fpm php5.6-cgi php-pear php5.6-mcrypt php5.6-curl php5.6-intl php5.6-xml php5.6-mbstring php5.6-gd curl php5.6-zip -y
sudo apt-get purge apache2
sudo apt-get install nginx nginx-extras -y
sudo apt-get install mysql-server -y
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs redis-server -y

# nginx config
sudo nano /etc/nginx/nginx.conf
worker_connections 1024;
geo $limited {
  default 1;
  # whitelist:
  95.213.231.70/32 0;
}

map $limited $limit {
  1 $binary_remote_addr;
  0 "";
}
limit_conn_zone   $limit  zone=addr:10m;
limit_req_zone  $limit  zone=one:10m   rate=1r/s;
client_max_body_size 50m;

# php.ini
sudo nano /etc/php/5.6/fpm/php.ini
short_open_tag = On
session.gc_maxlifetime = 2592000
memory_limit = 1024M

# php5.6-fpm config
sudo nano /etc/php/5.6/fpm/pool.d/www.conf
pm.max_children = 600
pm.start_servers = 240
pm.min_spare_servers = 160
pm.max_spare_servers = 320
sudo service php5.6-fpm restart

# mysql config
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
sql_mode=NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
max_connections        = 500
slow_query_log = 1
slow_query_log_file    = /var/log/mysql/mysql-slow.log
long_query_time = 2

sudo apt-get install git -y
cd /var/www
git clone https://atanych_@bitbucket.org/sms-voteru/helpdesk.git
git clone https://atanych_@bitbucket.org/sms-voteru/gateway.git
git clone https://atanych_@bitbucket.org/sms-voteru/api_hd.git
cd /var/www/helpdesk
<create database helpdesk>
<create database gateway>
cp /var/www/helpdesk/config/db.sample.php /var/www/helpdesk/config/db.php
cp /var/www/helpdesk/config/db-gateway.sample.php /var/www/helpdesk/config/db-gateway.php
cp /var/www/helpdesk/config/params-local.sample.php /var/www/helpdesk/config/params-local.php
cp /var/www/helpdesk/config/mailgun.sample.php /var/www/helpdesk/config/mailgun.php
cp /var/www/gateway/config/db.sample.php /var/www/gateway/config/db.php
cp /var/www/gateway/config/params-local.sample.php /var/www/gateway/config/params-local.php
cp /var/www/helpdesk/web/js/widget/new/params.sample.js /var/www/helpdesk/web/js/widget/new/params.js
mkdir /var/www/helpdesk/web/images/users/client
mkdir /var/www/helpdesk/web/images/users/temp
sudo chmod 777 -R /var/www/helpdesk/web/images/users
sudo chmod 777 -R /var/www/helpdesk/web/images/users/client
sudo chmod 777 -R /var/www/gateway/web/images
sudo chmod 777 -R /var/www/helpdesk/web/assets/
sudo chmod 777 -R /var/www/helpdesk/runtime/
sudo chmod 777 -R /var/www/helpdesk/web/assets/
sudo mkdir /var/log/gateway
sudo chmod 777 -R /var/log/gateway
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer global require "fxp/composer-asset-plugin:~1.1.1"
composer install
php yii migrate
sudo npm install -g bower
sudo npm install -g gulp-cli
npm install


cd /var/www/gateway
composer install
sudo nano /etc/nginx/sites-enabled/gateway

