#!/bin/bash
source tls-check-functions.sh

check-tls-hue() {
  HUE_CONFIG=$(mktemp -t hue_config.XXXXXXXXXX)
  HUE_SERVER_CONFIG=$(mktemp -t hue_server_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/hue/roleConfigGroups/hue-HUE_SERVER-BASE/config
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/HUE-1/roleConfigGroups/HUE-1-HUE_SERVER-BASE/config > ${HUE_SERVER_CONFIG}

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/hue/config > ${HUE_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/HUE-1/config > ${HUE_CONFIG}

  cm_grep_json ${HUE_SERVER_CONFIG} ssl_enable HUE_SSL_ENABLED
  cm_grep_json ${HUE_SERVER_CONFIG} ssl_cacerts HUE_SSL_CACERT_PATH
  cm_grep_json ${HUE_SERVER_CONFIG} ssl_certificate HUE_SSL_CERT_PATH
  cm_grep_json ${HUE_SERVER_CONFIG} ssl_private_key HUE_SSL_KEY_PATH
  cm_grep_json ${HUE_CONFIG} hue_service_safety_valve HUE_SAFETY_VALVE


  SERVICE_TLS_CHECK="HUE TLS Enabled"
  if [ -z "${HUE_SSL_ENABLED}" ] || [ "${HUE_SSL_ENABLED}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HUE TLS CA Cert"
  if [ -z "${HUE_SSL_CACERT_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HUE TLS Certificate Path"
  if [ -z "${HUE_SSL_CERT_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HUE TLS Key Path"
  if [ -z "${HUE_SSL_KEY_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="HUE Safety Valve in Place"
  if [ -z "${HUE_SAFETY_VALVE}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi


  rm -f ${HUE_CONFIG}
  rm -f ${HUE_SERVER_CONFIG}
}
