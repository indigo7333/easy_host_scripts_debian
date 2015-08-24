IP=`dig +short myip.opendns.com @resolver1.opendns.com`;
if [ ! $IP ]
then 
	echo "enter IP address please";
	exit
fi
echo "deb http://ftp.debian.org/debian wheezy-backports main contrib non-free" >> /etc/apt//sources.list
apt-get update
apt-get upgrade
apt-get install phpmyadmin mysql-server php5-mysql apache2 nginx php5-sqlite php5-gd procmail php5-imap php5-curl libapache2-mod-rpaf ftp-upload
#procmail needed for lockfile function
apt-get -t wheezy-backports install nginx-full
a2enmod rewrite
echo "NameVirtualHost 127.0.0.1:8080
Listen 127.0.0.1:8080" > /etc/apache2/ports.conf

echo "user www-data;
worker_processes 4;
pid /var/run/nginx.pid;

events {
        worker_connections 2048;
        multi_accept on;      
        use epoll;
}

http {  sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
      	reset_timedout_connection on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        server_tokens off;
        server_names_hash_bucket_size 128;
        client_max_body_size 128M;
        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        gzip on;
        gzip_http_version  1.1;
        gzip_vary          on;
        gzip_comp_level    4;
        gzip_proxied any;
        gzip_min_length 1400;
        gzip_static off;
        gzip_types text/plain text/xml text/css text/javascript text/js application/x-javascript font/woff application/font-woff application/x-font-woff image/jpeg;
        gzip_disable "MSIE [1-6]\.";


        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}
" > /etc/nginx/nginx.conf

echo "server {
        listen  80; ## listen for ipv4; this line is default and implied
        root /usr/share/nginx/www;
        index index.html index.htm;
        server_name $IP;
" >  /etc/nginx/sites-enabled/default
echo 'location / {
proxy_pass http://127.0.0.1:8080/;
proxy_redirect http://127.0.0.1:8080/ /;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $remote_addr;
proxy_connect_timeout 120;
proxy_send_timeout 120;
proxy_read_timeout 180;
}

}
' >> /etc/nginx/sites-enabled/default

echo 'LockFile ${APACHE_LOCK_DIR}/accept.lock
PidFile ${APACHE_PID_FILE}
Timeout 65
KeepAlive Off
MaxKeepAliveRequests 100
KeepAliveTimeout 5


<IfModule mpm_prefork_module>
    StartServers          10
    MinSpareServers       10
    MaxSpareServers      50
    MaxClients          150
    MaxRequestsPerChild   100
</IfModule>
User ${APACHE_RUN_USER}
Group ${APACHE_RUN_GROUP}

AccessFileName .htaccess
<Files ~ "^\.ht">
    Order allow,deny
    Deny from all
    Satisfy all
</Files>

DefaultType None
HostnameLookups Off
ErrorLog ${APACHE_LOG_DIR}/error.log
LogLevel warn
Include mods-enabled/*.load
Include mods-enabled/*.conf
Include ports.conf
LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
Include conf.d/
ServerTokens ProductOnly
ServerSignature Off

Include sites-enabled/
' > /etc/apache2/apache2.conf

echo "<VirtualHost 127.0.0.1:8080>
        ServerName $IP
        ServerAdmin support@exmple.com
        DocumentRoot /var/www
        <Directory /var/www>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        LogLevel warn
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-enabled/default

chmod 777 -R /var/log/apache2
chmod 777 -R /var/log/nginx


sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 127M/g' /etc/php5/*/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 127M/g' /etc/php5/*/php.ini
sed -i 's/session.gc_probability = 0/session.gc_probability = 1/g' /etc/php5/*/php.ini
sed -i 's/session.gc_divisor = 1000/session.gc_divisor = 100/g' /etc/php5/*/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 5400/g' /etc/php5/*/php.ini


rm /etc/apache2/sites-enabled/000-default
/etc/init.d/apache2 restart
/etc/init.d/nginx restart
