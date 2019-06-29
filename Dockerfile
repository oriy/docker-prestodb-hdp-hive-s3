FROM prestodb/hdp2.6-hive

# https://github.com/prestodb/docker-images/blob/master/prestodb/hdp2.6-hive/Dockerfile

ENV PRESTO_VERSION=0.229

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-AKIkey}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-AKIkeySecret}

ENV JAVA_HOME=/usr/java/latest
ENV PRESTO_HOME=/opt/presto
ENV HIVE_HOME=/usr/hdp/current/hive-metastore/../hive
ENV PRESTO_DATA=${PRESTO_HOME}/data

RUN curl -L https://repo1.maven.org/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz -o /tmp/presto-server.tgz && \
    tar -xzf /tmp/presto-server.tgz -C /opt && \
    ln -s /opt/presto-server-${PRESTO_VERSION} ${PRESTO_HOME} && \
    mkdir -p ${PRESTO_DATA} && \
    rm -f /tmp/presto-server.tgz

RUN curl -L https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar -o ${PRESTO_HOME}/presto-cli && \
    chmod +x ${PRESTO_HOME}/presto-cli && \
    ln -s ${PRESTO_HOME}/presto-cli /presto-cli
# presto-cli --server hive-metastore:8889 --catalog hive

COPY prestodb/etc ${PRESTO_HOME}/etc
COPY prestodb/hive/hive-site.xml /etc/hive/conf/hive-site.xml
COPY prestodb/hive/hive-env.sh /etc/hive/conf/conf.server/hive-env.sh

RUN ln -s ${HIVE_HOME}/etc/rc.d/init.d/hive-metastore /etc/init.d/hive-metastore
RUN ln -s ${HIVE_HOME}/etc/rc.d/init.d/hive-server2 /etc/init.d/hive-server2

COPY prestodb/init_prestodb.sh /init_prestodb.sh
COPY prestodb/hive_load_partitions.sql /hive_load_partitions.sql

EXPOSE 3306
EXPOSE 9083
EXPOSE 8889

VOLUME ["${PRESTO_HOME}/etc", "${PRESTO_DATA}"]

WORKDIR ${PRESTO_HOME}

# CHANGE TIMEZONE to UTC
RUN ln -snf "/usr/share/zoneinfo/UTC" /etc/localtime && echo "UTC" > /etc/timezone

ENTRYPOINT ["/init_prestodb.sh"]
