#!/bin/bash

enable-tls-solr() {
  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "solr_use_ssl",
        "value" : "true"
      }, {
        "name" : "solr_https_keystore_file",
        "value" : "'${KEYSTORE_PATH}'"
      }, {
        "name" : "solr_https_keystore_password",
        "value" : "'${KEYSTORE_PASSWORD}'"
      }, {
        "name" : "solr_https_truststore_file",
        "value" : "'${TRUSTSTORE_PATH}'"
      }, {
        "name" : "solr_https_truststore_password",
        "value" : "'${TRUSTSTORE_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/solr/config
}
