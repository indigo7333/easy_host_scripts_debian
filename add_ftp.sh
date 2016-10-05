#usage $1 - main_user , $2 - ftp_user, $3 - ftp_folder
main_user=$1
ftp_user=$2
ftp_folder=$3 # www/yoursite.com
directory="/home/${main_user}/${ftp_folder}/"
useradd --home $directory --gid $main_user $ftp_user
chmod 775 $directory
chmod 775 /home/${main_user}/www/
