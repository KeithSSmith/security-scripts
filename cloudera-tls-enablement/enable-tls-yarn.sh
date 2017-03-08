#!/bin/bash

enable-tls-yarn() {
  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "hadoop_secure_web_ui",
        "value" : "true"
      }, {
        "name" : "ssl_server_keystore_location",
        "value" : "'${KEYSTORE_PATH}'"
      }, {
        "name" : "ssl_server_keystore_keypassword",
        "value" : "'${KEYSTORE_PASSWORD}'"
      }, {
        "name" : "ssl_server_keystore_password",
        "value" : "'${KEYSTORE_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/yarn/config
}
