####
## WEB
####
# php, node, redis
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -y
sudo apt-get install php php7.1-cli php7.1-common php7.1-mysql php7.1-gd php7.1-fpm php7.1-cgi php-pear php7.1-mcrypt php7.1-curl php7.1-intl php7.1-xml php7.1-mbstring curl php7.1-zip -y
sudo apt-get purge apache2
sudo apt-get install nginx nginx-extras -y

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo add-apt-repository ppa:chris-lea/redis-server
sudo apt-get update
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
post_max_size = 20M
upload_max_filesize = 20M
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
git clone https://chathelpdesk@bitbucket.org/sms-voteru/rails-helpdesk.git

cp /var/www/helpdesk/config/db.sample.php /var/www/helpdesk/config/db.php
cp /var/www/helpdesk/config/db-gateway.sample.php /var/www/helpdesk/config/db-gateway.php
cp /var/www/helpdesk/config/db-statistics.sample.php /var/www/helpdesk/config/db-statistics.php
cp /var/www/helpdesk/config/params-local.sample.php /var/www/helpdesk/config/params-local.php
cp /var/www/helpdesk/config/mailer.sample.php /var/www/helpdesk/config/mailer.php
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
sudo npm install -g gulp-cli # sudo yarn add -g gulp-cli

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
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = helpdesk
binlog_do_db = helpdesk_statistics
binlog_do_db = gateway

binlog-ignore-db = mysql
binlog-ignore-db = sys
binlog-ignore-db = performance_schema
binlog-ignore-db = information_schema


GRANT REPLICATION SLAVE ON *.* TO 'slaveuser'@'%' IDENTIFIED BY 'vol4ara';
FLUSH PRIVILEGES;

# SLAVE https://ruhighload.com/post/%D0%9A%D0%B0%D0%BA+%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B8%D1%82%D1%8C+MySQL+Master-Slave+%D1%80%D0%B5%D0%BF%D0%BB%D0%B8%D0%BA%D0%B0%D1%86%D0%B8%D1%8E
relay-log = /var/log/mysql/mysql-relay-bin.log
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = helpdesk
binlog_do_db = helpdesk_statistics
binlog_do_db = gateway

binlog-ignore-db = mysql
binlog-ignore-db = sys
binlog-ignore-db = performance_schema
binlog-ignore-db = information_schema

CHANGE MASTER TO
  MASTER_HOST='10.100.19.11',
  MASTER_USER='slaveuser',
  MASTER_PASSWORD='vol4ara',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='mysql-bin.000003',
  MASTER_LOG_POS=154,
  MASTER_CONNECT_RETRY=10; # SHOW MASTER STATUS;
  
START SLAVE;
SHOW SLAVE STATUS\G

CREATE DATABASE helpdesk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE helpdesk_statistics CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'seva1980';


####
## DB_GW 
####
CREATE DATABASE gateway CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'seva1980';



# ruby
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
cd /tmp
curl -sSL https://get.rvm.io -o rvm.sh
cat /tmp/rvm.sh | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 2.4.2
rvm @global do gem install bundler
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:george-edison55/cmake-3.x
sudo apt-get update
sudo apt-get install cmake libmysqlclient-dev libmagickwand-dev -y
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
vim ~/scripts/deploy_api.sh
<add [bash] deploy_api>
vim ~/.bash_profile
<add alias> alias deploy_api="bash --login ~/scripts/deploy_api.sh"
source ~/.bash_profile
mkdir /var/www/api_hd/tmp && mkdir /var/www/api_hd/tmp/pids
cp /var/www/api_hd/config/puma.sample.rb /var/www/api_hd/config/puma.rb
vim /var/www/api_hd/config/puma.rb
<add daemonize>
mkdir /var/www/api_hd/tmp/sockets && touch /var/www/api_hd/tmp/sockets/puma.sock
sudo chmod 777 /var/www/api_hd/tmp/sockets/puma.sock
deploy_api

# rails-helpdesk
cp /var/www/rails-helpdesk/config/database.sample.yml /var/www/rails-helpdesk/config/database.yml
vim /var/www/rails-helpdesk/config/database.yml
sudo vim /usr/local/bin/rails_hd
sudo chmod 777 /usr/local/bin/rails_hd
vim ~/scripts/deploy_rails.sh
vim ~/.bash_profile
mkdir /var/www/rails-helpdesk/tmp && mkdir /var/www/rails-helpdesk/tmp/pids
cp /var/www/rails-helpdesk/config/puma.sample.rb /var/www/rails-helpdesk/config/puma.rb
vim /var/www/rails-helpdesk/config/puma.rb
<add daemonize>
mkdir /var/www/rails-helpdesk/tmp/sockets && touch /var/www/rails-helpdesk/tmp/sockets/puma.sock
sudo chmod 777 /var/www/rails-helpdesk/tmp/sockets/puma.sock
deploy_rails

# elixir
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install esl-erlang
sudo apt-get install elixir
mix local.hex
mix deps.get
cp /var/www/stats/config/prod.secret.sample.exs /var/www/stats/config/prod.secret.exs
MIX_ENV=prod mix compile



####
## LIVE-CHAT
####
sudo apt-get install nginx nginx-extras nodejs redis-server git -y
cd /var/www
git clone https://chathelpdesk@bitbucket.org/sms-voteru/life_chat.git
cd /var/www/life_chat
bundle install
cp /var/www/life_chat/config/database.sample.yml /var/www/life_chat/config/database.yml
cp /var/www/life_chat/config/puma.sample.rb /var/www/life_chat/config/puma.rb
sudo vim /usr/local/bin/life_chat
sudo chmod 777 /usr/local/bin/life_chat
mkdir ~/scripts
vim ~/scripts/deploy_chat.sh
mkdir /var/www/life_chat/tmp && mkdir /var/www/life_chat/tmp/pids
vim /var/www/life_chat/config/puma.rb
<add daemonize>
mkdir /var/www/life_chat/tmp/sockets && touch /var/www/life_chat/tmp/sockets/puma.sock
sudo chmod 777 /var/www/life_chat/tmp/sockets/puma.sock


####
## PYTHON
####
apt-get -y install python-pip
pip install requests
mkdir /var/www/helpdesk/smart
chmod 777 -R /var/www/helpdesk/smart
