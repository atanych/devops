# 1. create kay and crt
sudo letsencrypt certonly -a webroot --webroot-path=/var/www/html -d chat2desk.com -d www.chat2desk.com
# 2. ssl_trusted_certificate /etc/ssl/desk.chat2brand/ca-certs.pem;
wget -O - https://letsencrypt.org/certs/isrgrootx1.pem https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem https://letsencrypt.org/certs/letsencryptauthorityx1.pem https://www.identrust.com/certificates/trustid/root-download-x3.html | tee -a ca-certs.pem> /dev/null
# 3. /etc/ssl/name_of_server
openssl dhparam -out dhparam.pem 2048
