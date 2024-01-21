# FROM registry.access.redhat.com/ubi8/ubi:8.9-1028
FROM docker.io/library/rockylinux:8.9

LABEL vendor=Qanope.io \
  io.qanope.maintainer="James Régis <james.regis@qanope.io>" \
  io.qanope.image-name="open-xchange-appsuite" \
  io.qanope.is-beta="no" \
  io.qanope.is-production="yes" \
  io.qanope.version="${TAG}" \
  io.qanope.release-date="2024-01-20"


ARG OX_GID=261
ARG OX_UID=2061

RUN dnf -y install epel-release && \
    dnf -y update && \
    dnf -y install -y httpd gnupg nc wget && \
    dnf -y clean all && rm -fr /var/log/*

COPY open-xchange.repo /etc/yum.repos.d/open-xchange.repo

RUN dnf -y install --nogpgcheck \
        open-xchange \
        hunspell open-xchange \
        open-xchange-spellcheck \
        open-xchange-admin \
        open-xchange-appsuite \
        open-xchange-appsuite-backend \
        open-xchange-appsuite-help-en-us \
        open-xchange-appsuite-manifest \
        open-xchange-authentication-database \
        open-xchange-authorization \
        open-xchange-caldav \
        open-xchange-carddav \
        open-xchange-core \
        open-xchange-dav \
        open-xchange-documents-collaboration \
        open-xchange-documentconverter \
        open-xchange-documentconverter-api \
        open-xchange-documents-backend \
        open-xchange-documents-help-en-us \
        open-xchange-documents-ui \
        open-xchange-documents-ui-static \
        open-xchange-file-distribution \
        open-xchange-grizzly \
        open-xchange-halo \
        open-xchange-hazelcast \
        open-xchange-hazelcast-community \
        open-xchange-mailstore \
        open-xchange-oauth \
        open-xchange-osgi \
        open-xchange-passwordchange-database \
        open-xchange-sessionstorage-hazelcast \
        open-xchange-documents-templates \
        open-xchange-smtp \
        open-xchange-xerces \
        open-xchange-l10n-*\
        open-xchange-dynamic-theme \
        vim \
        nc \
	tmux \
	httpd \
	iproute && \
    dnf -y clean all && rm -fr /var/log/*

VOLUME [ "/sys/fs/cgroup" ]

COPY proxy_http.conf /etc/httpd/conf.d/proxy_http.conf
COPY ox.conf /etc/httpd/conf.d/ox.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir -p -m 0777 /ox /ox/store /ox/etc && \
    chown -R open-xchange:open-xchange /ox && \
    echo 'PATH=/opt/open-xchange/sbin:$PATH' >>/root/.bashrc

RUN sed -i -e '/ADDON_SQL_LONG=addon-sql/a MYSQL_CLIENT_PROTOCOL=TCP' /opt/open-xchange/sbin/initconfigdb

VOLUME /ox/store /ox/etc /var/log/httpd /var/log/open-xchange

EXPOSE 80

ENTRYPOINT /usr/local/bin/entrypoint.sh

