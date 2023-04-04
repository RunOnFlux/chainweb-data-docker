# syntax=docker/dockerfile:experimental
# Run as
#
# --ulimit nofile=64000:64000
# BUILD PARAMTERS
ARG UBUNTUVER=22.04
FROM ubuntu:${UBUNTUVER}

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl gnupg git cron lsof jq supervisor \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN set -eux; \
	groupadd -r postgres --gid=999; \
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql

ENV PG_VERSION=13 \
    PG_USER=postgres \
    PG_LOGDIR=/var/log/postgresql \
    PGDATA=/var/lib/postgresql/data \
    FONTCONFIG_FILE=/etc/fonts/fonts.conf \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LOCALE_ARCHIVE=/usr/lib/locale/locale-archive \
    NIX_PATH=nixpkgs=/root/.nix-defexpr/channels/nixpkgs:/root/.nix-defexpr/channels \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    PATH=/root/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl sudo locales \
      postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
 && rm -rf /var/lib/apt/lists/*

RUN rm /etc/postgresql/13/main/pg_hba.conf
RUN rm /etc/postgresql/13/main/postgresql.conf

RUN mkdir -p /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY chainweb-data.sh /chainweb-data.sh
COPY postgres_init.sh /postgres_init.sh
COPY backfill.sh /backfill.sh
COPY gaps.sh /gaps.sh
COPY postgres.sh /postgres.sh
COPY nix.conf /tmp/nix.conf
COPY pg_hba.conf /etc/postgresql/13/main/pg_hba.conf
COPY check-health.sh /check-health.sh
COPY postgresql.conf /etc/postgresql/13/main/postgresql.conf

VOLUME /var/lib/postgresql/data

RUN chmod 755 /chainweb-data.sh
RUN chmod 755 /backfill.sh
RUN chmod 755 /gaps.sh
RUN chmod 755 /check-health.sh
RUN chmod 755 /postgres_init.sh
RUN chmod 755 /postgres.sh


EXPOSE 8888/tcp

HEALTHCHECK --start-period=10m --interval=1m --retries=5 --timeout=20s CMD /check-health.sh

WORKDIR "/var/lib/postgresql/data"

ENTRYPOINT ["/usr/bin/supervisord"]
