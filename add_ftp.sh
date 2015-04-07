#usage $1 - main_user , $2 - ftp_user
main_user=$1
ftp_user=$2
directory="/home/${main_user}/www/${ftp_user}/"
useradd --home $directory --gid $main_user $ftp_user
