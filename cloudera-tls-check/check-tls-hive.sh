#!/bin/bash
source tls-check-functions.sh

check-tls-hive() {
  HIVE_CONFIG=$(mktemp -t hive_config.XXXXXXXXXX)
  # HS2_CONFIG=$(mktemp -t hs2_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/hive/config > ${HIVE_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/HIVE-1/config > ${HIVE_CONFIG}

  # curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  # --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  # https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/hive/roleConfigGroups/hive-HIVESERVER2-BASE/config > ${HS2_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/HIVE-1/roleConfigGroups/HIVE-1-HIVESERVER2-BASE/config > ${HS2_CONFIG}

  cm_grep_json ${HIVE_CONFIG} hiveserver2_enable_ssl HIVE_TLS_ENABLED
  cm_grep_json ${HIVE_CONFIG} hiveserver2_keystore_path HIVE_KEYSTORE_PATH
  cm_grep_json ${HIVE_CONFIG} hiveserver2_truststore_file HIVE_TRUSTSTORE_PATH
  # cm_grep_json ${HS2_CONFIG} ssl_enabled HS2_TLS_ENABLED
  # cm_grep_json ${HS2_CONFIG} ssl_server_keystore_location HS2_KEYSTORE_PATH


  SERVICE_TLS_CHECK="Hive TLS Enabled"
  if [ -z "${HIVE_TLS_ENABLED}" ] || [ "${HIVE_TLS_ENABLED}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Hive TLS Keystore"
  if [ -z "${HIVE_KEYSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Hive TLS Truststore"
  if [ -z "${HIVE_TRUSTSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  # SERVICE_TLS_CHECK="Hive Server 2 TLS Enabled"
  # if [ -z "${HS2_TLS_ENABLED}" ] || [ "${HS2_TLS_ENABLED}" != 'true' ]
  # then
  #   failed "${SERVICE_TLS_CHECK}" "Disabled"
  # else
  #   passed "${SERVICE_TLS_CHECK}" "Enabled"
  # fi
  #
  # SERVICE_TLS_CHECK="Hive Server 2 TLS Keystore"
  # if [ -z "${HS2_KEYSTORE_PATH}" ]
  # then
  #   failed "${SERVICE_TLS_CHECK}" "Disabled"
  # else
  #   passed "${SERVICE_TLS_CHECK}" "Enabled"
  # fi

  rm -f ${HIVE_CONFIG}
  # rm -f ${HS2_CONFIG}
}
