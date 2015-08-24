<?
//usage, $1-site name $2-user  $3=force_ssl=1 or 2  $4-ssl_cert $5=ssl_bundle 6=ssl_key $7 - 1 or 2 strong ssl sec, 
  $site_name=$argv[1];
  $user=$argv[2];
  $key=$argv[6];
$cert=$argv[4];
$force_ssl=$argv[3];
$strong_ssl=$argv[7];
 $bundle=$argv[5];
 if($key && $cert && $bundle) {   $ssl="yes"; } 

 $config_apache='<VirtualHost 127.0.0.1:8080>
        ServerAdmin com@'.$site_name.'
        ServerName '.$site_name.'
	ServerAlias www.'.$site_name.'
        DocumentRoot /home/'.$user.'/www/'.$site_name.'
        <Directory />
                Options FollowSymLinks
                AllowOverride All
        </Directory>
        <Directory /home/'.$user.'/www/'.$site_name.'>
                Options -Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>


        ErrorLog /home/'.$user.'/logs/apache/'.$site_name.'_error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel error

        CustomLog /home/'.$user.'/logs/apache/'.$site_name.'_access.log combined

        AddType application/x-httpd-php .php .php3 .php4 .php5 .phtml
        php_admin_value upload_tmp_dir "/home/'.$user.'/mod-tmp"
        php_admin_value session.save_path "/home/'.$user.'/mod-tmp"
</VirtualHost>';
  $config_nginx='server {'; if($ssl=="yes") { $config_nginx.="
listen *:443 ssl spdy;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
"; }

$config_nginx.='
listen *:80; ## listen for ipv4
server_name '.$site_name.' www.'.$site_name.';
access_log /home/'.$user.'/logs/nginx/'.$site_name.'_access.log;
error_log /home/'.$user.'/logs/nginx/'.$site_name.'_error.log;
';
if($force_ssl=="1") {
 $config_nginx.='add_header Strict-Transport-Security max-age=31536000;
 if ($scheme = http) {
        return 301 https://$server_name$request_uri;
    }
';
}
$config_nginx.= '
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
# Перенаправление на back-end
location / {
proxy_pass http://127.0.0.1:8080/;
proxy_redirect http://127.0.0.1:8080/ /;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $remote_addr;
proxy_connect_timeout 120;
proxy_send_timeout 120;
proxy_read_timeout 180;
}
# Статическиое наполнение отдает сам nginx
# back-end этим заниматься не должен
location ~* \.(jpg|jpeg|gif|png|ico|css|bmp|swf|js|txt|woff|woff2)$ {
 root /home/'.$user.'/www/'.$site_name.';
 #expires           0;
 #add_header        Cache-Control private;
 
 add_header        Cache-Control public;
 expires 10d;
 access_log off;

}
';
if($ssl=="yes") {$config_nginx.="
ssl_certificate /home/$user/ssl/$site_name/ssl.crt;
ssl_certificate_key /home/$user/ssl/$site_name/ssl.key;
ssl_stapling on;
ssl_stapling_verify on;
ssl_dhparam /home/$user/ssl/$site_name/dhparam.pem
ssl_client_certificate /home/$user/ssl/$site_name/ssl.trusted;
ssl_crl /home/$user/ssl/$site_name/ssl.trusted;
ssl_trusted_certificate /home/$user/ssl/$site_name/ssl.trusted;
ssl_prefer_server_ciphers on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
ssl_session_tickets on;
ssl_session_cache shared:SSL:50m;
ssl_session_timeout 4h;

";

if($strong_ssl==2) { $config_nginx.="ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5;"; }
else { $config_nginx.="ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';"; }



$config_nginx.='
}
';
                      

if($ssl=="yes")
 {
  exec("mkdir /home/$user/ssl/");
  exec("mkdir /home/$user/ssl/$site_name");
  exec("chmod 777 -R /home/$user/ssl");
  exec("chown www-data:$user -R /home/$user/ssl/");
  echo "cat $cert $bundle > /home/$user/ssl/$site_name/ssl.crt";
  exec("cat $cert $bundle > /home/$user/ssl/$site_name/ssl.crt");
  exec("cat $bundle > /home/$user/ssl/$site_name/ssl.trusted");
  exec("cp $key /home/$user/ssl/$site_name/ssl.key");
  if(!file_exists("/home/$user/ssl/$site_name/dhparam.pem") )  { exec("openssl dhparam -out /home/$user/ssl/$site_name/dhparam.pem 2048"); }
 } 
exec("mkdir /home/$user/www");
exec("mkdir /home/$user/www/$site_name");
exec("mkdir /home/$user/logs");
exec("mkdir /home/$user/logs/apache");
exec("mkdir /home/$user/logs/nginx");
exec("mkdir /home/$user/mod-tmp");
exec("chown www-data:$user /home/$user/mod-tmp");
exec("chmod 777 -R /home/$user/mod-tmp");
exec("chown -R www-data:$user /home/$user/logs"); 
exec("chmod 777 -R /home/$user/logs");
exec("chown $user:$user /home/$user/www");
exec("chown $user:$user /home/$user/www/$site_name");


file_put_contents("/etc/nginx/sites-enabled/$site_name", $config_nginx);
file_put_contents("/etc/apache2/sites-enabled/$site_name", $config_apache);

exec("/etc/init.d/apache2 restart");
exec("/etc/init.d/nginx restart");