#!/bin/bash
source tls-check-functions.sh

check-tls-yarn() {
  YARN_CONFIG=$(mktemp -t yarn_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/yarn/config > ${YARN_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/YARN-1/config > ${YARN_CONFIG}

  cm_grep_json ${YARN_CONFIG} hadoop_secure_web_ui YARN_SSL_WEBUI_ENABLED
  cm_grep_json ${YARN_CONFIG} ssl_server_keystore_location YARN_SSL_KEYSTORE_PATH


  SERVICE_TLS_CHECK="YARN Web UI TLS Enabled"
  if [ -z "${YARN_SSL_WEBUI_ENABLED}" ] || [ "${YARN_SSL_WEBUI_ENABLED}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="YARN TLS Keystore"
  if [ -z "${YARN_SSL_KEYSTORE_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi


  rm -f ${YARN_CONFIG}
}
