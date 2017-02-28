#!/bin/bash

enable-tls-hive() {
  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "hiveserver2_enable_ssl",
        "value" : "true"
      }, {
        "name" : "hiveserver2_keystore_path",
        "value" : "'${KEYSTORE_PATH}'"
      }, {
        "name" : "hiveserver2_keystore_password",
        "value" : "'${KEYSTORE_PASSWORD}'"
      }, {
        "name" : "hiveserver2_truststore_file",
        "value" : "'${TRUSTSTORE_PATH}'"
      }, {
        "name" : "hiveserver2_truststore_password",
        "value" : "'${TRUSTSTORE_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/hive/config

  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "ssl_enabled",
        "value" : "true"
      }, {
        "name" : "ssl_server_keystore_location",
        "value" : "'${KEYSTORE_PATH}'"
      }, {
        "name" : "ssl_server_keystore_password",
        "value" : "'${KEYSTORE_PATH}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/hive/roleConfigGroups/hive-HIVESERVER2-BASE/config
}
