#!/bin/bash
source tls-check-functions.sh

check-tls-spark() {
  SPARK_CONFIG=$(mktemp -t spark_config.XXXXXXXXXX)

  curl -s -X GET -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/spark_on_yarn/roleConfigGroups/spark_on_yarn-GATEWAY-BASE/config > ${SPARK_CONFIG}
  # curl -s -X GET -u admin:admin -i \
  # http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/SPARK_ON_YARN-1/roleConfigGroups/SPARK_ON_YARN-1-GATEWAY-BASE/config > ${SPARK_CONFIG}

  cm_grep_json ${SPARK_CONFIG} "spark-conf/spark-defaults.conf_client_config_safety_valve" SPARK_SAFETY_VALVE


  SERVICE_TLS_CHECK="Spark Safety Valve for RPC Protection"
  if [ -z "${SPARK_SAFETY_VALVE}" ] || [ "${SPARK_SAFETY_VALVE}" != 'true' ]
  then
    failed "${SERVICE_TLS_CHECK}" "Disabled"
  else
    passed "${SERVICE_TLS_CHECK}" "Enabled"
  fi


  rm -f ${SPARK_CONFIG}
}
