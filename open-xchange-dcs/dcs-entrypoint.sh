#!/bin/bash -e
#

# color to be more friendly ..
RED='\033[0;31m'
BRed='\033[1;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
BGreen='\033[1;32m'
UBlue='\033[4;34m'
BYellow='\033[1;33m'


OX_DCSDB_DB_ROOT_PASSWORD=${OX_CONFIG_DATABASE_ROOT_PASSWORD:-"root_password"}

OX_DCSDB_DB_USER=${OX_DCSDB_DB_USER:-"dcsdb"}
OX_DCSDB_DB_PASSWORD=${OX_DCSDB_DB_PASSWORD:-"dcsdb_password"}
OX_DCSDB_DB_HOST=${OX_DCSDB_DB_HOST:-"mariadb"}


# check if DB_HOST is reachable before proceed
while ! nc -z $OX_DCSDB_DB_HOST 3306; do
  echo -e "${BRed}*** This container cannot reach DB host $OX_DCSDB_DB_HOST ***${NC}"
  sleep 5
done

# # Add Open-Xchange to binary path
# echo PATH=$PATH:/opt/open-xchange/sbin/ >> ~/.bashrc && . ~/.bashrc

mkdir -p /var/log/open-xchange/documents-collaboration
touch /var/log/open-xchange/documents-collaboration/documents-collaboration.log

chown -R open-xchange:open-xchange /var/log/open-xchange

# configure DCS
sed -i -e "s/db.username=.*$/db.username=$OX_DCSDB_DB_USER/g" /etc/documents-collaboration/dcs.properties
sed -i -e "s/db.password=.*$/db.password=$OX_DCSDB_DB_PASSWORD/g" /etc/documents-collaboration/dcs.properties
sed -i -e "s/db.host=.*$/db.host=$OX_DCSDB_DB_HOST/g" /etc/documents-collaboration/dcs.properties

# initilalize database
echo -e "${BGreen} Initializing DCD database ... ${NC}"
/usr/share/open-xchange-documents-collaboration/bin/initdcsdb.sh --dcsdb-pass=${OX_DCSDB_DB_PASSWORD} --mysql-root-passwd=${OX_DCSDB_DB_ROOT_PASSWORD} -a -i

# run documents-collabration service
echo -e "${BGreen} Launching Documents Collaboration Service ... ${NC}"
/usr/share/open-xchange-documents-collaboration/bin/com.openexchange.office.dcs -Duser.timezone=UTC --spring.config.location=file:/etc/documents-collaboration/dcs.properties --logging.config=/etc/documents-collaboration/logback-spring.xml &

exec bash -c 'while [ 1 == 1 ];
  do tail -500f /var/log/open-xchange/documents-collaboration/documents-collaboration.log;
  echo Have patience, waiting for server to start; sleep 5; done'

