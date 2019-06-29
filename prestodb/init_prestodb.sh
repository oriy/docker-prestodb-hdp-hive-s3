#!/usr/bin/env bash

function title() {
  echo
  echo '----------------------------'
  echo "$1"
  echo '----------------------------'
  echo
}

function hiveSchemaTool() {
  hive --service schemaTool -dbType mysql "$1"
}



title "Mysql service"
service mysqld start

title "Hadoop Namenode"
hdfs namenode  2>&1 > /var/log/hadoop-hdfs/hadoop-hdfs-namenode.log &

title "Hive Metastore schema"
hiveSchemaTool -info 2>/dev/null
hive_status=$?

set -eo pipefail
shopt -s nullglob

if [[ ${hive_status} -ne 0 ]]; then
    hiveSchemaTool -initSchema
    hiveSchemaTool -info
fi

title "Hive Metastore service"
service hive-metastore start

title "Hive Server 2 service"
service hive-server2 start

title "Presto Server"
exec /opt/presto/bin/launcher run