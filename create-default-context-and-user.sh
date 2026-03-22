#!/bin/env bash
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

CONTEXT_NAME="Example Context"
DOMAIN="example.com"

OX_ADMIN_MASTER_PASSWORD=`yq e '.spec.containers[] | select (.name=="appsuite").env[] | select (.name=="OX_ADMIN_MASTER_PASSWORD") | .value' Pod.yml`
OX_CONTEXT_ADMIN_PASSWORD=`yq e '.spec.containers[] | select (.name=="appsuite").env[] | select (.name=="OX_CONTEXT_ADMIN_PASSWORD") | .value' Pod.yml`

echo -e "${BRed} Create a new context ... ${NC}\n"

podman exec open-xchange-appsuite /opt/open-xchange/sbin/createcontext -A oxadminmaster -P ${OX_ADMIN_MASTER_PASSWORD} -c 2 -u oxadmin -d ${CONTEXT_NAME} -g Admin -s User -p ${OX_CONTEXT_ADMIN_PASSWORD} -L ${DOMAIN} -e oxadmin@${DOMAIN} -q 1024 --contextname ${DOMAIN} --access-combination-name=all


echo -e "${BRed} Create a new user ... ${NC}\n"
podman exec open-xchange-appsuite /opt/open-xchange/sbin/createuser  --username 'john' --displayname 'John(example simple)' --givenname 'John' --surname 'Doe' --password tototiti001 --email 'john@example.com' --imaplogin 'john@example.com' --contextid 2 -A oxadmin -P ${OX_CONTEXT_ADMIN_PASSWORD}

echo -e  "You can now login with the following credentials: \n"
echo -e "login: ${BGreen}john@example.com${NC}\n"
echo -e "password: ${BGreen}tototiti001${NC}\n"
echo -e "Open-xchange appsuite URL: ${BGreen} http://localhost:8080/appsuite/ ${NC}\n"
