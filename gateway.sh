server {
  listen 80;
  server_name gateway.sms-vote.ru;

  location ~ /.well-known {
    root /var/www/html;
    allow all;
  }


  location / {
    # Redirect all HTTP requests to HTTPS with a 301 Moved Permanently response.
    return 301 https://gateway.sms-vote.ru/$request_uri;
  }
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  ssl_certificate /etc/letsencrypt/live/gateway.sms-vote.ru/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/gateway.sms-vote.ru/privkey.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;

  # Diffie-Hellman parameter for DHE ciphersuites, recommended 2048 bits
  ssl_dhparam /etc/ssl/gateway.sms-vote.ru/dhparam.pem;
  ssl_protocols TLSv1.2;
  ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
  ssl_prefer_server_ciphers on;
  # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
  add_header Strict-Transport-Security max-age=15768000;
  # OCSP Stapling ---
  # fetch OCSP records from URL in ssl_certificate and cache them
  ssl_stapling on;
  ssl_stapling_verify on;
  ## verify chain of trust of OCSP response using Root CA and Intermediate certs
  ssl_trusted_certificate /etc/ssl/gateway.sms-vote.ru/ca-certs.pem;

  resolver 8.8.8.8 8.8.4.4 valid=300s;
  root /var/www/gateway/web;
  index index.php;
  server_name gateway.sms-vote.ru;

  location / {
		limit_req   zone=one  burst=90  nodelay;
		limit_conn addr 150;
    try_files $uri $uri/ /index.php;
  }
 
  error_page 404 /404.html; 
  error_page 500 502 503 504 /50x.html;

  location = /50x.html {
    root /usr/share/nginx/www;
  }
 
  location ~ \.php$ {
    include fastcgi_params;
    fastcgi_param APP_ENV prod;

    try_files $uri =404;
    fastcgi_pass unix:/run/php/php5.6-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  } 
}
