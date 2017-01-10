#!/bin/bash
#Enable TLS Level 3 for Cloudera Manager Agents and Server
#http://www.cloudera.com/documentation/enterprise/latest/topics/cm_sg_config_tls_agent_auth.html
source tls-functions.sh

main() {
  generic_entry "Enter the Cloudera Manager hostname that the Cloudera Manager Server is on and press [ENTER]: " CLOUDERA_MANAGER_HOSTNAME
  generic_entry "Enter the Cloudera Manager Server Admin username and press [ENTER]: " CLOUDERA_MANAGER_USER
  directory_entry "Enter the base directory (Default: /opt/cloudera/security) where certificates are stored and press [ENTER]: " CERTIFICATE_DIRECTORY "/opt/cloudera/security"
  password_entry "Enter existing password for the Truststore and press [Enter]: " TRUSTSTORE_PASSWORD
  pem_for_ssh_check

  for HOST in $(cat /tmp/hosts)
  do
    HOSTNAME="hostname; "
    TASK_CM_AGENT_PW="printf 'Storing Truststore password in a location that the Cloudera Manager Agents can read from ...\n'; "
    CM_AGENT_PW="echo ${TRUSTSTORE_PASSWORD} > /etc/cloudera-scm-agent/agentkey.pw; "
    TASK_CM_AGENT_CONFIG="printf 'Making a backup of the original Cloudera Manager Agents config.ini ...\n'; "
    CM_AGENT_CONFIG="cat /etc/cloudera-scm-agent/config.ini.level-2 | sed -e \"s|# client_key_file=|client_key_file=${CERTIFICATE_DIRECTORY}/x509/cmagent.key|\" -e \"s|# client_cert_file=|client_cert_file=${CERTIFICATE_DIRECTORY}/x509/cmagent.pem|\" -e \"s|# client_keypw_file=|client_keypw_file=/etc/cloudera-scm-agent/agentkey.pw|\" > /etc/cloudera-scm-agent/config.ini.level-3; "
    TASK_CP_AGENT_CONFIG="printf 'Enabling TLS Level 3 for Cloudera Manager Agents config.ini ...\n'; "
    CP_AGENT_CONFIG="cp /etc/cloudera-scm-agent/config.ini.level-3 /etc/cloudera-scm-agent/config.ini; "

    SSH_COMMAND=${HOSTNAME}${TASK_CM_AGENT_PW}${CM_AGENT_PW}${TASK_CM_AGENT_CONFIG}${CM_AGENT_CONFIG}${TASK_CP_AGENT_CONFIG}${CP_AGENT_CONFIG}

    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"
  done

  printf 'Updating Cloudera Manager Server settings to TLS Level 3  ...\n'
  curl -X PUT -u ${CLOUDERA_MANAGER_USER} -i \
  --cacert "${CERTIFICATE_DIRECTORY}/CAcerts/cachain.pem" \
  -H "content-type:application/json" \
  -d '{ "items" :
        [
          {"name" : "NEED_AGENT_VALIDATION", "value" : "true"},
          {"name" : "TRUSTSTORE_PATH", "value" : "'${CERTIFICATE_DIRECTORY}'/jks/truststore.jks"},
          {"name" : "TRUSTSTORE_PASSWORD", "value" : "'${TRUSTSTORE_PASSWORD}'"}
        ]
      }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/cm/config

  printf '\nRestarting Cloudera Manager Server ...\n'
  systemctl restart cloudera-scm-server

  for HOST in $(cat /tmp/hosts)
  do
    HOSTNAME="hostname; "
    TASK_RESTART_CM_AGENT="printf 'Restarting the Cloudera Manager Agents to enable TLS Level 3 ...\n'; "
    RESTART_CM_AGENT="systemctl restart cloudera-scm-agent; "

    SSH_COMMAND="${HOSTNAME}${TASK_RESTART_CM_AGENT}${RESTART_CM_AGENT}"

    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"
  done
}

main "${@}"
