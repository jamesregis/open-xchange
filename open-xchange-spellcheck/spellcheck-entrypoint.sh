#!/bin/bash -e

# color to be more friendly ..
NC='\033[0m' # No Color
BGreen='\033[1;32m'


# Add Open-Xchange to binary path
# echo PATH=$PATH:/opt/open-xchange/sbin/ >> ~/.bashrc && . ~/.bashrc

mkdir -p /var/log/open-xchange/spellcheck
touch /var/log/open-xchange/spellcheck/spellcheck.log

chown -R open-xchange:open-xchange /var/log/open-xchange/spellcheck

# configure spellcheck
echo -e "${BGreen} Launching OpenXchange SpellCheck Service ... ${NC}"
/opt/open-xchange/spellcheck/bin/oxspell -c /opt/open-xchange/spellcheck/etc/spellcheck.properties &

exec bash -c 'while [ 1 == 1 ];
  do tail -500f /var/log/open-xchange/spellcheck/spellcheck.log;
  echo Have patience, waiting for server to start; sleep 5; done'

