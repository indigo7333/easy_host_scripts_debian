#!/bin/sh
# Usage ../ssl_script.ssh common_name path_to_certifiate
# The following script will create a certificate and key in one file

echodo()
{
    echo "${@}"
    (${@})
}

yearmon()
{
    date '+%Y%m%d'
}

C=Australia
ST=SA
L=Adelaid
O=cyertech_au
OU=nes
DATE=`yearmon`
CN=$1


openssl req -x509 -nodes -days 3000 -newkey rsa:2048 -keyout $2 -out $2 <<EOF
${C}
${ST}
${L}
${O}
${OU}
${CN}
$USER@${CN}
.
.
EOF 