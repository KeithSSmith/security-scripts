#!/bin/bash

enable-tls-hue() {
  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "ssl_enable",
        "value" : "true"
      }, {
        "name" : "ssl_cacerts",
        "value" : "'${PEM_CA_PATH}'"
      }, {
        "name" : "ssl_certificate",
        "value" : "'${PEM_CERT_PATH}'"
      }, {
        "name" : "ssl_private_key",
        "value" : "'${PEM_KEY_PATH}'"
      }, {
        "name" : "ssl_private_key_password",
        "value" : "'${PEM_KEY_PASSWORD}'"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/hue/roleConfigGroups/hue-HUE_SERVER-BASE/config

  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "hue_service_safety_valve",
        "value" : "[desktop]\n[[session]]\nsecure=true\nhttp-only=true\nttl=86400\n[[auth]]\nidle_session_timeout=1800\n[beeswax]\n[[ssl]]\nenable=true\ncacerts='${PEM_CA_PATH}'\nvalidate=true\n[impala]\nclose_queries=true\n[[ssl]]\nenable=true\ncacerts='${PEM_CA_PATH}'\nvalidate=true\n"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/hue/config
}
