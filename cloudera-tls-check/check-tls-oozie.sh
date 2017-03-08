#!/bin/bash
source tls-check-functions.sh

check-tls-oozie() {
  OOZIE_CONFIG=$(mktemp -t oozie_config.XXXXXXXXXX)
  OOZIE_SERVER_CONFIG=$(mktemp -t oozie_server_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/oozie/config > ${OOZIE_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/OOZIE-1/config > ${OOZIE_CONFIG}

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/oozie/roleConfigGroups/oozie-OOZIE_SERVER-BASE/config > ${OOZIE_SERVER_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/OOZIE-1/roleConfigGroups/OOZIE-1-OOZIE_SERVER-BASE/config > ${OOZIE_SERVER_CONFIG}

  cm_grep_json ${OOZIE_CONFIG} oozie_use_ssl OOZIE_SSL_ENABLED
  cm_grep_json ${OOZIE_SERVER_CONFIG} oozie_https_keystore_file OOZIE_SSL_KEYSTORE_PATH
  cm_grep_json ${OOZIE_SERVER_CONFIG} oozie_https_truststore_file OOZIE_SSL_TRUSTSTORE_PATH


  SERVICE_TLS_CHECK="Ooozie TLS Enabled"
  if [ -z "${OOZIE_SSL_ENABLED}" ] || [ "${OOZIE_SSL_ENABLED}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Oozie TLS Keystore"
  if [ -z "${OOZIE_SSL_KEYSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Oozie TLS Truststore"
  if [ -z "${OOZIE_SSL_TRUSTSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi


  rm -f ${OOZIE_CONFIG}
  rm -f ${OOZIE_SERVER_CONFIG}
}
