IP=`dig +short myip.opendns.com @resolver1.opendns.com`;
if [ ! $IP ]
then
        echo "enter IP address please";
        exit
fi

apt-get install pure-ftpd
apt-get install openssl
echo "10000 11000" > /etc/pure-ftpd/conf/PassivePortRange
echo $IP > /etc/pure-ftpd/conf/ForcePassiveIP
echo 1 > /etc/pure-ftpd/conf/TLS
mkdir -p /etc/ssl/private/
openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
chmod 600 /etc/ssl/private/pure-ftpd.pem
echo 'yes' > /etc/pure-ftpd/conf/NoAnonymous
echo 'yes' > /etc/pure-ftpd/conf/ChrootEveryone
/etc/init.d/pure-ftpd restart
