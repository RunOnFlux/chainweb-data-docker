ARG UBUNTUVER=22.04
FROM ubuntu:${UBUNTUVER}

RUN apt-get update -y && apt-get upgrade -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl unzip gnupg git cron lsof jq supervisor lsb-release \
 && echo $(lsb_release -cs) \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list \
 && gpg --no-default-keyring --keyring /usr/share/keyrings/postgresql-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7FCC7D46ACCC4CF8
 
RUN set -eux; \
	groupadd -r postgres --gid=999; \
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql
	
ENV PG_VERSION=15 \
    PG_USER=postgres \
    PG_LOGDIR=/var/log/postgresql \
    PGDATA=/var/lib/postgresql/data \
    FONTCONFIG_FILE=/etc/fonts/fonts.conf \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LOCALE_ARCHIVE=/usr/lib/locale/locale-archive 

RUN apt-get update -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl sudo locales postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && dpkg-reconfigure -f noninteractive locales \
 && rm -rf /var/lib/apt/lists/*
 
WORKDIR "/usr/local/bin"

RUN PACKAGE=$(curl --silent "https://api.github.com/repos/kadena-io/chainweb-data/releases/latest" | jq -r .assets[].browser_download_url | grep "$UBUNTUVER") \
&& echo "Downloading file: ${PACKAGE}" \
&& wget "${PACKAGE}" \
&& unzip * \
&& rm -rf *.zip \
&& chmod +x chainweb-data
 
RUN rm /etc/postgresql/${PG_VERSION}/main/pg_hba.conf
RUN rm /etc/postgresql/${PG_VERSION}/main/postgresql.conf
RUN mkdir -p /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY chainweb-data.sh /chainweb-data.sh
COPY postgres_init.sh /postgres_init.sh
COPY backfill.sh /backfill.sh
COPY gaps.sh /gaps.sh
COPY postgres.sh /postgres.sh
COPY pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf
COPY check-health.sh /check-health.sh
COPY postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf

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
