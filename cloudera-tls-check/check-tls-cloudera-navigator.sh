#!/bin/bash
source tls-check-functions.sh

check-tls-cloudera-navigator() {
  NAV_CONFIG=$(mktemp -t nav_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/cm/service/roleConfigGroups/mgmt-NAVIGATORMETASERVER-BASE/config > ${NAV_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://localhost:7180/api/${CM_API_VERSION}/cm/service/roleConfigGroups/mgmt-NAVIGATORMETASERVER-BASE/config > ${NAV_CONFIG}

  cm_grep_json ${NAV_CONFIG} ssl_enabled NAV_SSL_ENABLED
  cm_grep_json ${NAV_CONFIG} ssl_server_keystore_location NAV_SSL_KEYSTORE_LOCATION

  SERVICE_TLS_CHECK="Cloudera Navigator TLS Enabled"
  if [ -z "${NAV_SSL_ENABLED}" ] || [ "${NAV_SSL_ENABLED}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Cloudera Navigator TLS Keystore"
  if [ -z "${NAV_SSL_KEYSTORE_LOCATION}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  rm -f ${NAV_CONFIG}
}
