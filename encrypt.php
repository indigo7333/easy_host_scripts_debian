sudo apt-get install -t jessie-backports certbot

DOMAIN=$1

sed -i '$ s/.$//' /etc/nginx/sites-enabled/$DOMAIN.conf

echo 'location ~ /.well-known {
                allow all;
}

}' >> /etc/nginx/sites-enabled/$DOMAIN.conf


/etc/init.d/nginx restart

sudo certbot certonly --webroot --webroot-path=/home/$USER/www/$DOMAIN -d $DOMAIN -d www.$DOMAIN
