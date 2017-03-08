#!/bin/bash
source tls-check-functions.sh

check-tls-solr() {
  SOLR_CONFIG=$(mktemp -t solr_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/solr/config > ${SOLR_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/SOLR-1/config > ${SOLR_CONFIG}

  cm_grep_json ${SOLR_CONFIG} solr_use_ssl SOLR_SSL_ENABLED
  cm_grep_json ${SOLR_CONFIG} solr_https_keystore_file SOLR_SSL_KEYSTORE_LOCATION
  cm_grep_json ${SOLR_CONFIG} solr_https_truststore_file SOLR_SSL_TRUSTSTORE_LOCATION


  SERVICE_TLS_CHECK="Solr TLS Enabled"
  if [ -z "${SOLR_SSL_ENABLED}" ] || [ "${SOLR_SSL_ENABLED}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Solr TLS Keystore"
  if [ -z "${SOLR_SSL_KEYSTORE_LOCATION}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi

  SERVICE_TLS_CHECK="Solr TLS Truststore"
  if [ -z "${SOLR_SSL_TRUSTSTORE_LOCATION}" ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi


  rm -f ${SOLR_CONFIG}
}
