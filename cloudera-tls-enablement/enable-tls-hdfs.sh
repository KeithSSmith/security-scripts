#!/bin/bash

enable-tls-hdfs() {
  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "hadoop_secure_web_ui",
        "value" : "true"
      }, {
        "name" : "hdfs_hadoop_ssl_enabled",
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
      }, {
        "name" : "ssl_client_truststore_location",
        "value" : "'${TRUSTSTORE_PATH}'"
      }, {
        "name" : "ssl_client_truststore_password",
        "value" : "'${TRUSTSTORE_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/hdfs/config

  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "dfs_datanode_http_port",
        "value" : "50075"
      }, {
        "name" : "dfs_datanode_port",
        "value" : "50010"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/hdfs/roleConfigGroups/hdfs-DATANODE-BASE/config

  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "dfs_data_transfer_protection",
        "value" : "privacy"
      }, {
        "name" : "dfs_encrypt_data_transfer",
        "value" : "true"
      }, {
        "name" : "dfs_encrypt_data_transfer_algorithm",
        "value" : "AES/CTR/NoPadding"
      }, {
        "name" : "hadoop_rpc_protection",
        "value" : "privacy"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/hdfs/config
}
