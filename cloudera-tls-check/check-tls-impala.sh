#!/bin/bash
source tls-check-functions.sh

check-tls-impala() {
  IMPALA_CONFIG=$(mktemp -t impala_config.XXXXXXXXXX)
  IMPALA_DAEMON_CONFIG=$(mktemp -t impala_daemon_config.XXXXXXXXXX)
  IMPALA_CATALOG_CONFIG=$(mktemp -t impala_catalog_config.XXXXXXXXXX)
  IMPALA_STATESTORE_CONFIG=$(mktemp -t impala_statestore_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/impala/config > ${IMPALA_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/IMPALA-1/config > ${IMPALA_CONFIG}

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/impala/roleConfigGroups/impala-IMPALAD-BASE/config > ${IMPALA_DAEMON_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/IMPALA-1/roleConfigGroups/IMPALA-1-IMPALAD-BASE/config > ${IMPALA_DAEMON_CONFIG}

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/impala/roleConfigGroups/impala-CATALOGSERVER-BASE/config > ${IMPALA_CATALOG_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/IMPALA-1/roleConfigGroups/IMPALA-1-CATALOGSERVER-BASE/config > ${IMPALA_CATALOG_CONFIG}

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/impala/roleConfigGroups/impala-STATESTORE-BASE/config > ${IMPALA_STATESTORE_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/IMPALA-1/roleConfigGroups/IMPALA-1-STATESTORE-BASE/config > ${IMPALA_STATESTORE_CONFIG}


  cm_grep_json ${IMPALA_CONFIG} client_services_ssl_enabled IMPALA_SSL_ENABLED
  cm_grep_json ${IMPALA_CONFIG} ssl_client_ca_certificate IMPALA_SSL_CLIENT_CA
  cm_grep_json ${IMPALA_CONFIG} ssl_server_certificate IMPALA_SSL_SERVER_CERT
  cm_grep_json ${IMPALA_CONFIG} ssl_private_key IMPALA_SSL_KEY_PATH

  cm_grep_json ${IMPALA_DAEMON_CONFIG} webserver_certificate_file IMPALA_DAEMON_CERT_PATH
  cm_grep_json ${IMPALA_DAEMON_CONFIG} webserver_private_key_file IMPALA_DAEMON_KEY_PATH

  cm_grep_json ${IMPALA_CATALOG_CONFIG} webserver_certificate_file IMPALA_CATALOG_CERT_PATH
  cm_grep_json ${IMPALA_CATALOG_CONFIG} webserver_private_key_file IMPALA_CATALOG_KEY_PATH

  cm_grep_json ${IMPALA_STATESTORE_CONFIG} webserver_certificate_file IMPALA_STATESTORE_CERT_PATH
  cm_grep_json ${IMPALA_STATESTORE_CONFIG} webserver_private_key_file IMPALA_STATESTORE_KEY_PATH


  SERVICE_TLS_CHECK="Impala TLS Enabled"
  if [ -z "${IMPALA_SSL_ENABLED}" ] || [ "${IMPALA_SSL_ENABLED}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Impala TLS Client CA"
  if [ -z "${IMPALA_SSL_CLIENT_CA}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Impala TLS Server Certificate"
  if [ -z "${IMPALA_SSL_SERVER_CERT}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Impala TLS Key Path"
  if [ -z "${IMPALA_SSL_KEY_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Impala Daemon TLS Certificate"
  if [ -z "${IMPALA_DAEMON_CERT_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Impala Daemon TLS Key"
  if [ -z "${IMPALA_DAEMON_KEY_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Impala Catalog Server TLS Certificate"
  if [ -z "${IMPALA_CATALOG_CERT_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Impala Catalog Server TLS Key"
  if [ -z "${IMPALA_CATALOG_KEY_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Impala Statestore TLS Certificate"
  if [ -z "${IMPALA_STATESTORE_CERT_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Impala Daemon TLS Key"
  if [ -z "${IMPALA_STATESTORE_KEY_PATH}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi


  rm -f ${IMPALA_CONFIG}
  rm -f ${IMPALA_DAEMON_CONFIG}
  rm -f ${IMPALA_CATALOG_CONFIG}
  rm -f ${IMPALA_STATESTORE_CONFIG}
}
