#usage $1=ftp_host $2=folder_name_ftp $3=ftp_pass $4=mysql_pass $5=hourly/daily/monthly  $6=pass
ftp_ip=$1
folder_name_ftp=$2
ftp_pass=$3
MYSQL_PASS=$4
FOLDER=$5
#DBS=$(`mysql -u root -h localhost --password="$(MYSQL_PASS)" -Bse 'show databases'`)
DBS="$(mysql -u root -h localhost --password="$MYSQL_PASS" -Bse 'show databases')"
for db in $DBS
do
 if [ $db = 'information_schema' ] || [ $db = 'phpmyadmin' ] || [ $db = 'performance_schema' ] || [ $db = 'mysql' ]
 then
	continue
 fi
 FILE=$db.gz
 mysqldump -u root -h localhost --password="${mysql_pass}" $db | gzip -9 > /tmp/$FILE
 gpg -o /tmp/$FILE.gpg --passphrase $6 -c /tmp/$FILE
 ftp-upload -h $ftp_ip --passive -u ftp_user --password $ftp_pass -d $folder_name_ftp/$FOLDER/mysql/ /tmp/$FILE.gpg
 rm /tmp/$FILE
 rm /tmp/$FILE.gpg
done
