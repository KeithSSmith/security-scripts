#!/bin/bash
source tls-check-functions.sh

check-tls-hdfs() {
  HDFS_CONFIG=$(mktemp -t hdfs_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/hdfs/config > ${HDFS_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/HDFS-1/config > ${HDFS_CONFIG}

  cm_grep_json ${HDFS_CONFIG} hdfs_hadoop_ssl_enabled HDFS_SSL_ENABLED
  cm_grep_json ${HDFS_CONFIG} ssl_server_keystore_location HDFS_SSL_KEYSTORE_LOCATION
  cm_grep_json ${HDFS_CONFIG} ssl_client_truststore_location HDFS_SSL_TRUSTSTORE_LOCATION
  cm_grep_json ${HDFS_CONFIG} dfs_data_transfer_protection HDFS_DATA_TRANSFER_PROTECTION
  cm_grep_json ${HDFS_CONFIG} hadoop_rpc_protection HDFS_RPC_PROTECTION

  SERVICE_TLS_CHECK="HDFS TLS Enabled"
  if [ -z "${HDFS_SSL_ENABLED}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HDFS TLS Keystore"
  if [ -z "${HDFS_SSL_KEYSTORE_LOCATION}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HDFS TLS Truststore"
  if [ -z "${HDFS_SSL_TRUSTSTORE_LOCATION}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HDFS Data Transfer Protection"
  if [ -z "${HDFS_DATA_TRANSFER_PROTECTION}" ] || [ "${HDFS_DATA_TRANSFER_PROTECTION}" != 'privacy' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HDFS RPC Protection"
  if [ -z "${HDFS_RPC_PROTECTION}" ] || [ "${HDFS_RPC_PROTECTION}" != 'privacy' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  rm -f ${HDFS_CONFIG}
}
