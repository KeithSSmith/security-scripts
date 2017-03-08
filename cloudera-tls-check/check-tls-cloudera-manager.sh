#!/bin/bash
source tls-check-functions.sh

check-tls-cloudera-manager() {
  CM_CONFIG=$(mktemp -t cm_config.XXXXXXXXXX)
  CM_MGMT_CONFIG=$(mktemp -t cm_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/cm/config > ${CM_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/cm/config > ${CM_CONFIG}

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/cm/service/config > ${CM_MGMT_CONFIG}
  # curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/cm/service/config > ${CM_MGMT_CONFIG}

  cm_grep_json ${CM_CONFIG} WEB_TLS CM_SERVER_TLS
  cm_grep_json ${CM_CONFIG} AGENT_TLS CM_AGENT_TLS
  cm_grep_json ${CM_CONFIG} NEED_AGENT_VALIDATION CM_AGENT_VALIDATION
  cm_grep_json ${CM_CONFIG} KEYSTORE_PATH CM_KEYSTORE_PATH
  cm_grep_json ${CM_CONFIG} TRUSTSTORE_PATH CM_TRUSTSTORE_PATH
  cm_grep_json ${CM_MGMT_CONFIG} ssl_client_truststore_location CM_MGMT_TRUSTSTORE_PATH


  SERVICE_TLS_CHECK="Cloudera Manager Server TLS Enabled"
  if [ -z "${CM_SERVER_TLS}" ] || [ "${CM_SERVER_TLS}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Coudera Management Services Truststore"
  if [ -z "${CM_MGMT_TRUSTSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="CM Agent TLS Enabled (Level 1)"
  if [ -z "${CM_AGENT_TLS}" ] || [ "${CM_AGENT_TLS}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="CM Agent TLS Validation (Level 3)"
  if [ -z "${CM_AGENT_VALIDATION}" ] || [ "${CM_AGENT_VALIDATION}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="CM Keystore Path"
  if [ -z "${CM_KEYSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="CM Truststore Path"
  if [ -z "${CM_TRUSTSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi


  rm -f ${CM_CONFIG}
  rm -f ${CM_MGMT_CONFIG}
}
