#usage $1=ftp_host $2=$users_backup $3=folder_name_ftp $4=ftp_pass $5hourly/daily/monthly  $6=pass_gpg
ftp_ip=$1
folder_name_ftp=$3
ftp_pass=$4
users_backup=( $2 )
FOLDER=$5


for user in "${users_backup[@]}"
do
	FILE=$user.tar.gz
	echo "$(date)" > /home/$user/backup_date.txt
	cd /home/$user
	tar --exclude='.' -czf /tmp/$FILE *
  gpg -o /tmp/$FILE.gpg --passphrase $6 -c /tmp/$FILE
	ftp-upload -h $ftp_ip --passive -u ftp_user --password $ftp_pass -d $host_name_ftp/$FOLDER/files/$user /tmp/$FILE.gpg
	rm /tmp/$FILE
  rm /tmp/$FILE.gpg
	rm /home/$user/backup_date.txt
done
                                                         