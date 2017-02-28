#!/bin/bash

enable-tls-cloudera-navigator() {
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
        "name" : "ssl_server_keystore_keypassword",
        "value" : "'${KEYSTORE_PASSWORD}'"
      }, {
        "name" : "ssl_server_keystore_password",
        "value" : "'${KEYSTORE_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/cm/service/roleConfigGroups/mgmt-NAVIGATORMETASERVER-BASE/config
}
