#!/bin/bash -e
#

# color to be more friendly ..
RED='\033[0;31m'
BRed='\033[1;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
BGreen='\033[1;32m'
BBlue='\033[1;34m'
BYellow='\033[1;33m'
UBlue='\033[4;34m'

OX_ETCBACKUP=/ox/etc

OX_CONFIG_DATABASE_ROOT_PASSWORD=${OX_CONFIG_DATABASE_ROOT_PASSWORD:-"root_password"}
OX_CONFIG_DATABASE_USER=${OX_CONFIG_DATABASE_USER:-"openxchange"}
OX_CONFIG_DATABASE_PASSWORD=${OX_CONFIG_DATABASE_PASSWORD:-"db_password"}
OX_CONFIG_DATABASE_HOST=${OX_CONFIG_DATABASE_HOST:-"mariadb"}

OX_ADMIN_MASTER_LOGIN=${OX_ADMIN_MASTER_LOGIN:-"oxadminmaster"}
OX_ADMIN_MASTER_PASSWORD=${OX_ADMIN_MASTER_PASSWORD:-"admin_master_password"}

OX_SERVER_NAME=${OX_SERVER_NAME:-"oxserver"}
OX_SERVER_MEMORY=${OX_SERVER_MEMORY:-"4096"}

OX_DCSDB_DB_USER=${OX_DCSDB_DB_USER:-"dcsdb"}
OX_DCSDB_DB_PASSWORD=${OX_DCSDB_DB_PASSWORD:-"dcsdb_password"}
OX_DCSDB_DB_HOST=${OX_DCSDB_DB_HOST:-"mariadb"}

OX_CONTEXT_ADMIN_LOGIN=${OX_CONTEXT_ADMIN_LOGIN:-"oxadmin"}
OX_CONTEXT_ADMIN_PASSWORD=${OX_CONTEXT_ADMIN_PASSWORD:-"oxadmin"}
OX_CONTEXT_ADMIN_EMAIL=${OX_CONTEXT_ADMIN_EMAIL:-"admin@example.com"}
OX_CONTEXT_ID=${OX_CONTEXT_ID:-"1"}

OX_DATADIR=${OX_DATADIR:-"/var/opt/filestore"}

# export OX_CONFIG_DB_USER=openxchange

echo "CONFIG_DATABASE_PASSWORD=${OX_CONFIG_DATABASE_PASSWORD}"
echo "ADMIN_MASTER_LOGIN=${OX_ADMIN_MASTER_LOGIN}"
echo "ADMIN_MASTER_PASSWORD=${OX_ADMIN_MASTER_PASSWORD}"
echo "SERVER_NAME=${OX_SERVER_NAME}"
echo "SERVER_MEMORY=${OX_SERVER_MEMORY}"
echo "CONTEXT_ADMIN_LOGIN=${OX_CONTEXT_ADMIN_LOGIN}"
echo "CONTEXT_ADMIN_PASSWORD=${OX_CONTEXT_ADMIN_PASSWORD}"
echo "CONTEXT_ADMIN_EMAIL=${OX_CONTEXT_ADMIN_EMAIL}"
echo "CONTEXT_ID=${OX_CONTEXT_ID}"

# check if DB_HOST is reachable before proceed
while ! nc -z $OX_CONFIG_DATABASE_HOST 3306; do
  echo -e "${BRed}*** This container cannot reach DB host $OX_CONFIG_DATABASE_HOST ***${NC}"
  sleep 10
done

mkdir -p /ox/{etc,store}
chown -R open-xchange:open-xchange /ox/{etc,store}

chown -R open-xchange:open-xchange /var/log/open-xchange $OX_DATADIR

#Add Open-Xchange to binary path
#echo PATH=$PATH:/opt/open-xchange/sbin/ >> ~/.bashrc && . ~/.bashrc

FIRST_TIME=0
if [ -d ${OX_ETCBACKUP}/settings ]; then
  cp -a ${OX_ETCBACKUP}/. /opt/open-xchange/etc/
else
  FIRST_TIME=1
  if ! touch ${OX_ETCBACKUP}/.checkwrite; then
    echo "** Directory ${OX_ETCBACKUP} must be writeable on first run **"
    echo "** In kubernetes: export OX_ETC_READONLY=false **"
    sleep 10
    exit 1
  fi

  sed -i -e "s/^com.openexchange.IPCheck=.*/com.openexchange.IPCheck=false/"\
    /opt/open-xchange/etc/server.properties
  sed -i -e "s/^com.openexchange.hazelcast.group.password=.*/com.openexchange.hazelcast.group.password=`head -c${1:-15} /dev/urandom|base64`/" \
    /opt/open-xchange/etc/hazelcast.properties
  [ -e /opt/open-xchange/etc/documents.properties ] && sed -i \
    -e "s/com.openexchange.capability.presentation=.*/com.openexchange.capability.presentation=true/" \
    -e "s/# com.openexchange.capability.text/com.openexchange.capability.text/1" \
    -e "s/# com.openexchange.capability.spreadsheet/com.openexchange.capability.spreadsheet/1" \
    /opt/open-xchange/etc/documents.properties
fi

if [ "$FIRST_TIME" == 1 ]; then
  echo -e "${BGreen}**** First time install ... ****${NC}"

  # create config database
  /opt/open-xchange/sbin/initconfigdb \
      --configdb-user=${OX_CONFIG_DATABASE_USER} \
      --configdb-pass=${OX_CONFIG_DATABASE_PASSWORD} \
      --configdb-dbname=configdb \
      --configdb-host=${OX_CONFIG_DATABASE_HOST} \
      --configdb-port=3306 \
      -a -i \
      --mysql-root-passwd=${OX_CONFIG_DATABASE_ROOT_PASSWORD} \
      --mysql-root-user=root

  # create server instance config
  /opt/open-xchange/sbin/oxinstaller \
      --no-license \
      --servername=${OX_SERVER_NAME} \
      --configdb-user=${OX_CONFIG_DATABASE_USER} \
      --configdb-pass=${OX_CONFIG_DATABASE_PASSWORD} \
      --configdb-readhost=${OX_CONFIG_DATABASE_HOST} \
      --configdb-readport=3306 \
      --configdb-writehost=${OX_CONFIG_DATABASE_HOST} \
      --configdb-writeport=3306 \
      --configdb-dbname=configdb \
      --master-pass=${OX_ADMIN_MASTER_PASSWORD} \
      --network-listener-host=localhost \
      --servermemory ${OX_SERVER_MEMORY}

  # start open-xchange
  /opt/open-xchange/sbin/triggerupdatethemes -u
  su -s /bin/bash open-xchange -c /opt/open-xchange/sbin/open-xchange &

  echo -e "${BBlue} Wait for OX .. ${NC}"
  while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8009)" != "404" ]]; do
    echo -e "Wait for Open-Xchange to be up and running ..."
    sleep 5;
  done

  while ! /opt/open-xchange/sbin/registerserver \
    --adminuser=${OX_ADMIN_MASTER_LOGIN} \
    --adminpass=${OX_ADMIN_MASTER_PASSWORD} \
    --name=${OX_SERVER_NAME}; do
      echo "-- Waiting on registerserver"
      sleep 5
  done;

  #Register filestore
  /opt/open-xchange/sbin/registerfilestore \
      --adminuser=${OX_ADMIN_MASTER_LOGIN} \
      --adminpass=${OX_ADMIN_MASTER_PASSWORD} \
      --storepath=file:${OX_DATADIR} \
      --storesize=1000000

  #Create groupware database
  /opt/open-xchange/sbin/registerdatabase \
      --adminuser=${OX_ADMIN_MASTER_LOGIN} \
      --adminpass=${OX_ADMIN_MASTER_PASSWORD} \
      --name=oxdatabase \
      --hostname=${OX_CONFIG_DATABASE_HOST} \
      --dbuser=${OX_CONFIG_DATABASE_USER} \
      --dbpasswd=${OX_CONFIG_DATABASE_PASSWORD} \
      --master=true

  #Create context
  while ! /opt/open-xchange/sbin/createcontext \
      --adminuser=${OX_ADMIN_MASTER_LOGIN} \
      --adminpass=${OX_ADMIN_MASTER_PASSWORD} \
      --contextid=${OX_CONTEXT_ID} \
      --username=${OX_CONTEXT_ADMIN_LOGIN} \
      --password=${OX_CONTEXT_ADMIN_PASSWORD} \
      --email=${OX_CONTEXT_ADMIN_EMAIL} \
      --displayname="Context Admin" \
      --givenname=Admin \
      --surname=Admin \
      --addmapping=defaultcontext \
      --quota=1024 \
      --access-combination-name=groupware_standard; do
      echo "-- Waiting on createcontext"
  done
fi

if [ "$FIRST_TIME" == 0 ]; then
  echo -e "${BGreen}*** Restart from an existing installation ***${NC}"
  # start open-xchange
  /opt/open-xchange/sbin/triggerupdatethemes -u
  su -s /bin/bash open-xchange -c /opt/open-xchange/sbin/open-xchange &
fi

# start apache
echo -e "${BGreen}*** Starting apache ***${NC}"
apachectl -d /etc/httpd -k start

# configuration for DCS
sed -i -e "s/db.username=.*$/db.username=$OX_DCSDB_DB_USER/g" /etc/documents-collaboration/dcs.properties
sed -i -e "s/db.password=.*$/db.password=$OX_DCSDB_DB_PASSWORD/g" /etc/documents-collaboration/dcs.properties
sed -i -e "s/db.host=.*$/db.host=$OX_DCSDB_DB_HOST/g" /etc/documents-collaboration/dcs.properties

# install Documents
sed -i -e "s/com.openexchange.capability.text=.*$/com.openexchange.capability.text=true/g" /opt/open-xchange/etc/documents.properties
sed -i -e "s/com.openexchange.capability.spredsheet=.*$/com.openexchange.capability.spreadsheet=true/g" /opt/open-xchange/etc/documents.properties
sed -i -e "s/# com.openexchange.capability.presentation=.*$/com.openexchange.capability.presentation=true/g" /opt/open-xchange/etc/documents.properties
sed -i -e "s/# com.openexchange.capability.presenter=.*$/com.openexchange.capability.presenter=true/g" /opt/open-xchange/etc/documents.properties

sed -i -e 's/1\.3/1\.4/g' /opt/open-xchange/etc/hunspell.properties

# update dcsdb credentials
echo "--- Change credentials for documents-collaboration ---"
sed -i -e "s/com.openexchange.dcs.client.database.userName=.*$/com.openexchange.dcs.client.database.userName=$OX_DCSDB_DB_USER/g" /opt/open-xchange/etc/documents-collaboration-client.properties
sed -i -e "s/com.openexchange.dcs.client.database.password=.*$/com.openexchange.dcs.client.database.password=$OX_DCSDB_DB_PASSWORD/g" /opt/open-xchange/etc/documents-collaboration-client.properties
sed -i -e "s/com.openexchange.dcs.client.database.connectionURL=.*$/com.openexchange.dcs.client.database.connectionURL=jdbc:mysql:\/\/$OX_DCSDB_DB_HOST:3306\/dcsdb/g" /opt/open-xchange/etc/documents-collaboration-client.properties


# update authentication method
sed -i -e "s/IMAP_SERVER=.*$/IMAP_SERVER=${IMAP_SERVER}/g" /opt/open-xchange/etc/imapauth.properties
sed -i -e "/scom.openexchange.mail.filter.server=.*$/com.openexchange.mail.filter.server=imap.recrulink.com/g" /opt/open-xchange/etc/mailfilter.properties
sed -i -e "s/com.openexchange.mail.mailServer=*.$/com.openexchange.mail.mailServer=imap.recrulink.com:143/g" /opt/open-xchange/etc/mail.properties


echo "*** Restarting open-xchange server ***"

export OX_PID=$(ps faux | grep "/bin/bash open-xchange" | grep -v grep | awk '{ print $2 }')
export OX_CHILD_PID=$(pgrep -laP $OX_PID | awk '{ print $1 }')

# kil all OX process and childs
for ox_child_pid in $OX_CHILD_PID; do
  kill -9 $ox_child_pid;
done;
echo "${BBlue}*** Kill main open-xchange process ***${NC}"
kill -9 $OX_PID;


# start open-xchange
su -s /bin/bash open-xchange -c /opt/open-xchange/sbin/open-xchange &

echo "*** Restart completed ***"

echo -e "${BBlue} Wait for OX .. ${NC}"
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost/appsuite/)" != "200" ]]; do
  echo -e "${BYellow} Wait for Open-Xchange to be up and running ...${NC}"
  sleep 5;
done

echo "*** Create backup configuration ***"

# copy configfile to backup location
mkdir -p ${OX_ETCBACKUP}/settings
cp -a /opt/open-xchange/etc/. ${OX_ETCBACKUP}/

# The server should be up and running
# /opt/open-xchange/sbin/createcontext -A oxadminmaster -P 'admin_master_password'  -c 2 -u oxadmin -d "Qanope Context" -g Admin -s User -p "admin_password"  -L qanope.ca -e oxadmin@qanope.ca -q 1024  --contextname qanope.ca --access-combination-name=all
# /opt/open-xchange/sbin/createuser  --username 'james' --displayname 'James(qanope simple)' --givenname 'James' --surname 'Regis' --password tototiti001 --email 'james@qanope.ca' --imaplogin 'james@qanope.ca' --contextid 2 -A oxadmin -P 'admin_password'

exec bash -c 'while [ 1 == 1 ];
  do tail -500f /var/log/open-xchange/open-xchange.log.0;
  echo Have patience, waiting for server to start; sleep 5; done'

