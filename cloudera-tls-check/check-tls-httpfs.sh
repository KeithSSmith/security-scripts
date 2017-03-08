#!/bin/bash
source tls-check-functions.sh

check-tls-httpfs() {
  HTTPFS_CONFIG=$(mktemp -t httpfs_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/hdfs/roleConfigGroups/hdfs-HTTPFS-BASE/config
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/HDFS-1/roleConfigGroups/HDFS-1-HTTPFS-BASE/config > ${HTTPFS_CONFIG}

  cm_grep_json ${HTTPFS_CONFIG} httpfs_use_ssl HTTPFS_SSL_ENABLED
  cm_grep_json ${HTTPFS_CONFIG} httpfs_https_keystore_file HTTPFS_SSL_KEYSTORE_PATH
  cm_grep_json ${HTTPFS_CONFIG} httpfs_https_truststore_file HTTPFS_SSL_TRUSTSTORE_PATH


  SERVICE_TLS_CHECK="HttpFS TLS Enabled"
  if [ -z "${HTTPFS_SSL_ENABLED}" ] || [ "${HTTPFS_SSL_ENABLED}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HttpFS TLS Keystore"
  if [ -z "${HTTPFS_SSL_KEYSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HttpFS TLS Truststore"
  if [ -z "${HTTPFS_SSL_TRUSTSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  rm -f ${HTTPFS_CONFIG}
}
