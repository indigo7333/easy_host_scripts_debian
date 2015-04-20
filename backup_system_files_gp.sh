#usage $1=ftp_host $2=folder_name_ftp $3=ftp_pass $4=pass_gpg

lockfile -r 0 /tmp/backup_system_files_gp.lock || exit 1

ftp_ip=$1
folder_name_ftp=$2
ftp_pass=$3
gpg_pass=$4

echo "$(date)" > /etc/backup_date.txt
cd /etc
FILE="etc.tar.gz"
tar --exclude='.' -czf /tmp/$FILE *
gpg -o /tmp/$FILE.gpg --passphrase $gpg_pass -c /tmp/$FILE
ftp-upload -h $ftp_ip --passive -u ftp_user --password $ftp_pass -d $folder_name_ftp /tmp/$FILE.gpg
rm /tmp/$FILE
rm /tmp/$FILE.gpg
rm /etc/backup_date.txt


rm -f /tmp/backup_system_files_gp.lock
                                                         