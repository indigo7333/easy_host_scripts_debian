#require IP if cloud 

IP=`dig +short myip.opendns.com @resolver1.opendns.com`;
echo "deb http://ftp.cyconet.org/debian wheezy-updates main non-free contrib" >> \
/etc/apt/sources.list.d/wheezy-updates.cyconet.list; \
aptitude update; aptitude install -t wheezy-updates debian-cyconet-archive-keyring vsftpd

echo "listen=YES
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_file=/var/log/vsftpd.log
async_abor_enable=YES
ascii_upload_enable=YES
ascii_download_enable=YES
ftpd_banner=Welcome to FTP server
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/private/vsftpd.pem
allow_writeable_chroot=YES
log_ftp_protocol=YES
dirlist_enable=YES
anon_mkdir_write_enable=No
anon_other_write_enable=No
anon_world_readable_only=No
force_dot_files=YES
pasv_enable=Yes
pasv_max_port=10300
pasv_min_port=10050
passwd_chroot_enable=YES" > /etc/vsftpd.conf
if [ $IP ]
then
	echo "pasv_address=$IP" >> /etc/vsftpd.conf
fi
/etc/init.d/vsftpd restart
