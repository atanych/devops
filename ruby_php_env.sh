####
## WEB
####
# php, node, redis
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -y
sudo apt-get install php
sudo apt-get install php7.1-cli php7.1-common php7.1-mysql php7.1-gd php7.1-fpm php7.1-cgi php-pear php7.1-mcrypt php7.1-curl php7.1-intl php7.1-xml php7.1-mbstring php7.1-gd curl php7.1-zip -y
sudo apt-get purge apache2
sudo apt-get install nginx nginx-extras -y
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs redis-server git -y

# nginx
sudo rm /etc/nginx/sites-enabled/default
sudo mkdir /usr/share/nginx/www && sudo chmod 777 -R /usr/share/nginx/www && sudo touch /usr/share/nginx/www/50x.html
sudo echo "500 error" >> /usr/share/nginx/www/50x.html
sudo vim /etc/nginx/sites-enabled/web
sudo vim /etc/nginx/nginx.conf

# events
worker_connections 1024;
# http
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
sudo vim /etc/php/7.1/fpm/php.ini
short_open_tag = On
session.gc_maxlifetime = 2592000
memory_limit = 1024M
date.timezone = Europe/Moscow
sudo vim /etc/php/7.1/cli/php.ini
date.timezone = Europe/Moscow

# php7.1-fpm config
sudo vim /etc/php/7.1/fpm/pool.d/www.conf
pm.max_children = 900
pm.start_servers = 360
pm.min_spare_servers = 240
pm.max_spare_servers = 480
request_terminate_timeout = 30s (is not used now)
#php_flag[display_errors] = on
#php_admin_value[error_log] = /var/log/fpm-php.www.log
#php_admin_flag[log_errors] = on

sudo service php7.1-fpm restart

cd /var/www
git clone https://chathelpdesk@bitbucket.org/sms-voteru/helpdesk.git
git clone https://chathelpdesk@bitbucket.org/sms-voteru/stats.git
git clone https://chathelpdesk@bitbucket.org/sms-voteru/api_hd.git

cp /var/www/helpdesk/config/db.sample.php /var/www/helpdesk/config/db.php
cp /var/www/helpdesk/config/db-gateway.sample.php /var/www/helpdesk/config/db-gateway.php
cp /var/www/helpdesk/config/db-statistics.sample.php /var/www/helpdesk/config/db-statistics.php
cp /var/www/helpdesk/config/params-local.sample.php /var/www/helpdesk/config/params-local.php
cp /var/www/helpdesk/config/mailgun.sample.php /var/www/helpdesk/config/mailgun.php
cp /var/www/helpdesk/config/redis.sample.php /var/www/helpdesk/config/redis.php
cp /var/www/helpdesk/config/log.sample.php /var/www/helpdesk/config/log-local.php
cp /var/www/helpdesk/config/mailer.sample.php /var/www/helpdesk/config/mailer-local.php
cp /var/www/helpdesk/config/file-system.sample.php /var/www/helpdesk/config/file-system.php
cp /var/www/helpdesk/web/js/widget/new/params.sample.js /var/www/helpdesk/web/js/widget/new/params.js
mkdir /var/www/helpdesk/web/images/users/client
mkdir /var/www/helpdesk/web/images/users/temp

sudo chmod 777 -R /var/www/helpdesk/web/images/users
sudo chmod 777 -R /var/www/helpdesk/web/images/users/client
sudo chmod 777 -R /var/www/helpdesk/web/assets/
sudo chmod 777 -R /var/www/helpdesk/runtime/

# composer
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer global require "fxp/composer-asset-plugin:~1.1.1"
composer install

php yii migrate
sudo npm install -g bower
sudo npm install -g gulp-cli

# yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
yarn install

# deploy script
mkdir ~/scripts
vim ~/scripts/deploy_php.sh
vim ~/.bash_profile
<add alias> alias deploy_php="bash --login ~/scripts/deploy_php.sh"
source ~/.bash_profile

####
## GATEWAY
####
git clone https://chathelpdesk@bitbucket.org/sms-voteru/gateway.git
composer install
cp /var/www/gateway/config/db.sample.php /var/www/gateway/config/db.php
cp /var/www/gateway/config/params-local.sample.php /var/www/gateway/config/params-local.php
cp /var/www/gateway/config/file-system.sample.php /var/www/gateway/config/file-system.php

sudo chmod 777 -R /var/www/gateway/web/images && sudo mkdir /var/log/gateway && sudo chmod 777 -R /var/log/gateway
php yii migrate

####
## DB_HD
####
sudo apt-get install mysql-server -y
# mysql config
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
sql_mode=NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
bind-address            = <server_ip>
max_connections        = 500
slow_query_log = 1
slow_query_log_file    = /var/log/mysql/mysql-slow.log
long_query_time = 2

CREATE DATABASE helpdesk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE helpdesk_statistics CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'vol4ara';

####
## DB_GW 
####
CREATE DATABASE gateway CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'vol4ara';



# ruby
\curl -L https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 2.3.0
rvm @global do gem install bundler
sudo apt-get install libmysqlclient-dev -y
cd /var/www/api_hd
ssh-keygen -t rsa -b 4096 -C "test@test.com"
cat ~/.ssh/id_rsa.pub
bundle install
cp /var/www/api_hd/config/database.sample.yml /var/www/api_hd/config/database.yml
vim /var/www/api_hd/config/database.yml
RAILS_ENV=production rake db:migrate
sudo vim /usr/local/bin/api_hd
sudo chmod 777 /usr/local/bin/api_hd
<add bash script>
nano ~/scripts/deploy_api.sh
<add [bash] deploy_api>
nano ~/.bash_profile
<add alias> alias deploy_api="bash --login ~/scripts/deploy_api.sh"
source ~/.bash_profile
mkdir /var/www/api_hd/tmp && mkdir /var/www/api_hd/tmp/pids
cp /var/www/api_hd/config/puma.sample.rb /var/www/api_hd/config/puma.rb
vim /var/www/api_hd/config/puma.rb
<add daemonize>
mkdir /var/www/api_hd/tmp/sockets && touch /var/www/api_hd/tmp/sockets/puma.sock
sudo chmod 777 /var/www/api_hd/tmp/sockets/puma.sock
deploy_api

