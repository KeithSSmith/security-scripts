#!/bin/bash

cluster_restart() {
  parameter_count_check "$#" 0

  deploy_client_configs
  restart_management_services
  sleep 120
  curl -X POST -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} --cacert ${CLOUDERA_MANAGER_CA_PEM} https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/commands/stop
  sleep 180
  curl -X POST -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} --cacert ${CLOUDERA_MANAGER_CA_PEM} https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/commands/start
}

deploy_client_configs() {
  parameter_count_check "$#" 0

  curl -X POST -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} --cacert ${CLOUDERA_MANAGER_CA_PEM} https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/commands/deployClientConfig
}

restart_management_services() {
  parameter_count_check "$#" 0

  curl -X POST -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} --cacert ${CLOUDERA_MANAGER_CA_PEM} https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/cm/service/commands/restart
}

restart_service() {
  parameter_count_check "$#" 1

  SERVICE="${1}"
  curl -X POST -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} --cacert ${CLOUDERA_MANAGER_CA_PEM} https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/${SERVICE}/commands/restart
}
