#!/bin/bash

enable-tls-impala() {
  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "client_services_ssl_enabled",
        "value" : "true"
      }, {
        "name" : "ssl_client_ca_certificate",
        "value" : "'${PEM_CA_PATH}'"
      }, {
        "name" : "ssl_server_certificate",
        "value" : "'${PEM_CERT_PATH}'"
      }, {
        "name" : "ssl_private_key",
        "value" : "'${PEM_KEY_PATH}'"
      }, {
        "name" : "ssl_private_key_password",
        "value" : "'${PEM_KEY_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/impala/config

  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "webserver_certificate_file",
        "value" : "'${PEM_CERT_PATH}'"
      }, {
        "name" : "webserver_private_key_file",
        "value" : "'${PEM_KEY_PATH}'"
      }, {
        "name" : "webserver_private_key_password_cmd",
        "value" : "'${PEM_KEY_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/impala/roleConfigGroups/impala-IMPALAD-BASE/config

  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "webserver_certificate_file",
        "value" : "'${PEM_CERT_PATH}'"
      }, {
        "name" : "webserver_private_key_file",
        "value" : "'${PEM_KEY_PATH}'"
      }, {
        "name" : "webserver_private_key_password_cmd",
        "value" : "'${PEM_KEY_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/impala/roleConfigGroups/impala-CATALOGSERVER-BASE/config

  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "webserver_certificate_file",
        "value" : "'${PEM_CERT_PATH}'"
      }, {
        "name" : "webserver_private_key_file",
        "value" : "'${PEM_KEY_PATH}'"
      }, {
        "name" : "webserver_private_key_password_cmd",
        "value" : "'${PEM_KEY_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/clusters/cluster/services/impala/roleConfigGroups/impala-STATESTORE-BASE/config
}
