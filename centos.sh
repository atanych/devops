sudo yum update
sudo yum -y install epel-release
sudo yum -y install nginx
systemctl enable nginx

# nginx
sudo mkdir /etc/nginx/sites-enabled
include /etc/nginx/sites-enabled/*.conf;
server_names_hash_bucket_size 64;
# open ports
semanage port -l | grep http_port_t

# redis
yum -y install redis
systemctl start redis
/usr/sbin/setsebool httpd_can_network_connect=1

# yarn
sudo wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
sudo yum -f install yarn

# php-fpm
sudo vi /etc/php-fpm.d/www.conf
listen = /var/run/php-fpm/php-fpm.sock
listen.owner = nginx
listen.group = nginx
user = nginx
group = nginx

sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# php http://drach.pro/blog/linux/item/132-lamp-for-centos-7-3
rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum-config-manager --enable remi-php71
yum -y install php php-opcache 
yum -y install php-fpm php-mysql php-gd php-pear php-mcrypt php-intl php-mbstring php-zip php-redis
curl -sL https://rpm.nodesource.com/setup_8.x | bash -
yum install -y nodejs git
------
vim /etc/php.ini


# mysql 
# https://www.tecmint.com/install-latest-mysql-on-rhel-centos-and-fedora/
wget http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
yum localinstall mysql57-community-release-el7-7.noarch.rpm
yum -y install mysql-community-server mysql-devel

service mysqld start
grep 'temporary password' /var/log/mysqld.log
SET GLOBAL validate_password_policy=LOW;


# composer
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer global require "fxp/composer-asset-plugin:~1.1.1"

# ruby
yum -y install cmake ImageMagick ImageMagick-devel
chown -R nginx:nginx puma.sock


# python
yum -y install python-pip
pip install requests
mkdir /var/www/helpdesk/smart
hown -R nginx:nginx /var/www/helpdesk/smart
chcon -R -t httpd_sys_rw_content_t /var/www/helpdesk/smart

# specific
chgrp -R nginx /var/www
sudo chgrp nginx ./assets
chcon -R -t httpd_sys_rw_content_t ./assets/
