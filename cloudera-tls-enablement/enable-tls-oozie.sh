#!/bin/bash

enable-tls-oozie() {
  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "oozie_use_ssl",
        "value" : "true"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/oozie/config

  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "oozie_https_keystore_file",
        "value" : "'${KEYSTORE_PATH}'"
      }, {
        "name" : "oozie_https_keystore_password",
        "value" : "'${KEYSTORE_PASSWORD}'"
      }, {
        "name" : "oozie_https_truststore_file",
        "value" : "'${TRUSTSTORE_PATH}'"
      }, {
        "name" : "oozie_https_truststore_password",
        "value" : "'${TRUSTSTORE_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/oozie/roleConfigGroups/oozie-OOZIE_SERVER-BASE/config
}
