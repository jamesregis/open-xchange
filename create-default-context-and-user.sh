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

echo -e "${BRed} Create a new context ... ${NC}\n"

#podman exec open-xchange-appsuite /opt/open-xchange/sbin/createcontext -A oxadminmaster -P 'admin_master_password'  -c 2 -u oxadmin -d "Example Context" -g Admin -s User -p "admin_password"  -L example.com -e oxadmin@example.com -q 1024 --contextname example.com --access-combination-name=all


echo -e "${BRed} Create a new user ... ${NC}\n"
#podman exec open-xchange-appsuite /opt/open-xchange/sbin/createuser  --username 'john' --displayname 'John(example simple)' --givenname 'John' --surname 'Doe' --password tototiti001 --email 'john@example.com' --imaplogin 'john@example.com' --contextid 2 -A oxadmin -P 'admin_password'

echo -e  "You can now login with the following credentials: \n"
echo -e "login: ${BGreen}john@example.com${NC}\n"
echo -e "password: ${BGreen}tototiti001${NC}\n"
echo -e "Open-xchange appsuite URL: ${BGreen} http://localhost:8080/appsuite/ ${NC}\n"
