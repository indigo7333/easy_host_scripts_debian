#usage $1=ftp_host $2=$users_backup $3=folder_name_ftp $4=ftp_pass $5=mysql_pass $6=hourly/daily/monthly
ftp_ip=$1
folder_name_ftp=$3
ftp_pass=$4
users_backup=( $2 )
MYSQL_PASS=$5
FOLDER=$6
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
 ftp-upload -h $ftp_ip --passive -u ftp_user --password $ftp_pass -d $folder_name_ftp/$FOLDER/mysql/ /tmp/$FILE
 rm /tmp/$FILE
done

for user in "${users_backup[@]}"
do
	FILE=$user.tar.gz
	echo "$(date)" > /home/$user/backup_date.txt
	cd /home/$user
	tar --exclude='.' -czf /tmp/$FILE *
	ftp-upload -h $ftp_ip --passive -u ftp_user --password $ftp_pass -d $folder_name_ftp/$FOLDER/files/$user /tmp/$FILE
	rm /tmp/$FILE
	rm /home/$user/backup_date.txt
done
                                                         