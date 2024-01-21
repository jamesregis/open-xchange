# FROM registry.access.redhat.com/ubi8/ubi:8.9-1028
FROM docker.io/library/rockylinux:8.9

LABEL vendor=Qanope.io \
  io.qanope.maintainer="James Régis <james.regis@qanope.io>" \
  io.qanope.image-name="open-xchange-dcs" \
  io.qanope.is-beta="no" \
  io.qanope.is-production="yes" \
  io.qanope.version="${TAG}" \
  io.qanope.release-date="2024-01-20"

ARG OX_GID=261
ARG OX_UID=2061

ENV OX_ADMIN_MASTER_LOGIN=oxadminmaster \
    OX_CONFIG_DB_HOST=db00 \
    OX_CONFIG_DB_NAME=oxdata \
    OX_CONFIG_DB_USER=openxchange \
    OX_CONTEXT_ADMIN_LOGIN=oxadmin \
    OX_CONTEXT_ADMIN_EMAIL=admin@domain.com \
    OX_CONTEXT_ID=1 \
    OX_SERVER_NAME=oxserver \
    OX_SERVER_MEMORY=2048 \
    OX_CONFIG_DB_HOST="mariadb" \
    OX_DB_PASSWORD="db_password" \
    OX_SERVER_NAME="oxserver" \
    OX_DATADIR="/var/opt/filestore" \
    OX_CONTEXT_ADMIN_EMAIL="admin@domain" \
    OX_ADMIN_MASTER_LOGIN="oxadminmaster" \
    OX_ADMIN_PASSWORD="admin_master_password" \
    OX_CONTEXT_ADMIN_LOGIN="oxadmin" \
    OX_SERVER_MEMORY="1024" \
    TZ="America/Toronto"


RUN dnf -y install epel-release && \
    dnf -y update && \
    dnf -y install -y httpd gnupg nc wget && \
    dnf -y clean all && rm -fr /var/log/*

COPY open-xchange.repo /etc/yum.repos.d/open-xchange.repo

RUN dnf -y install --nogpgcheck \
    open-xchange-documents-collaboration \
    vim \
    nc \
	tmux \
	httpd \
	iproute && \
    dnf -y clean all && rm -fr /var/log/*


COPY dcs-entrypoint.sh /usr/local/bin/dcs-entrypoint.sh
ENTRYPOINT /usr/local/bin/dcs-entrypoint.sh
