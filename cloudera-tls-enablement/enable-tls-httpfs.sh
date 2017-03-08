#!/bin/bash

enable-tls-httpfs() {
  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "httpfs_use_ssl",
        "value" : "true"
      }, {
        "name" : "httpfs_https_keystore_file",
        "value" : "'${KEYSTORE_PATH}'"
      }, {
        "name" : "httpfs_https_keystore_password",
        "value" : "'${KEYSTORE_PASSWORD}'"
      }, {
        "name" : "httpfs_https_truststore_file",
        "value" : "'${TRUSTSTORE_PATH}'"
      }, {
        "name" : "httpfs_https_truststore_password",
        "value" : "'${TRUSTSTORE_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/hdfs/roleConfigGroups/hdfs-HTTPFS-BASE/config
}
