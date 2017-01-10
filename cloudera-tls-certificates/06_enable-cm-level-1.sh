#!/bin/bash
#Enable TLS for Cloudera Manager Server
#http://www.cloudera.com/documentation/enterprise/latest/topics/cm_sg_tls_browser.html
source tls-functions.sh

main() {
  generic_entry "Enter the Cloudera Manager hostname that the Cloudera Manager Server is on and press [ENTER]: " CLOUDERA_MANAGER_HOSTNAME
  generic_entry "Enter the Cloudera Manager Server Admin username and press [ENTER]: " CLOUDERA_MANAGER_USER
  directory_entry "Enter the base directory (Default: /opt/cloudera/security) where certificates are stored and press [ENTER]: " CERTIFICATE_DIRECTORY "/opt/cloudera/security"

  printf 'Enabling TLS for Cloudera Manager Agent communication ...\n'

  curl -X PUT -u ${CLOUDERA_MANAGER_USER} -i \
  --cacert "${CERTIFICATE_DIRECTORY}/CAcerts/cachain.pem" \
  -H "content-type:application/json" \
  -d '{ "items" :
        [
          {"name" : "AGENT_TLS", "value" : "true"}
        ]
      }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/cm/config

  printf '\n'
  pem_for_ssh_check

  for HOST in $(cat /tmp/hosts)
  do
    HOSTNAME="hostname; "
    TASK_CP_AGENT_CONFIG="printf 'Making a backup of the original Cloudera Manager Agents config.ini ...\n'; "
    CP_AGENT_CONFIG="cp /etc/cloudera-scm-agent/config.ini /etc/cloudera-scm-agent/config.ini.original; "
    TASK_ENABLE_AGENT_TLS="printf 'Turning on TLS in configuration file for the Cloudera Manager Agent ...\n'; "
    ENABLE_AGENT_TLS="cat /etc/cloudera-scm-agent/config.ini.original | sed \"s/use_tls=0/use_tls=1/\" > /etc/cloudera-scm-agent/config.ini.level-1; "
    TASK_CP_LVL1_AGENT_CONFIG="printf 'Making the TLS Level 1 configuration file the currently used configurtion for the Cloudera Manager Agent ...\n'; "
    CP_LVL1_AGENT_CONFIG="cp /etc/cloudera-scm-agent/config.ini.level-1 /etc/cloudera-scm-agent/config.ini; "
    TASK_RESTART_CM_AGENT="printf 'Restarting Cloudera Manager Agent ...\n'; "
    RESTART_CM_AGENT="systemctl restart cloudera-scm-agent; "

    SSH_COMMAND="${HOSTNAME}${TASK_CP_AGENT_CONFIG}${CP_AGENT_CONFIG}${TASK_ENABLE_AGENT_TLS}${ENABLE_AGENT_TLS}${TASK_CP_LVL1_AGENT_CONFIG}${CP_LVL1_AGENT_CONFIG}${TASK_RESTART_CM_AGENT}${RESTART_CM_AGENT}"

    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"

    printf 'Restarting Cloudera Manager Server ...\n'
    systemctl restart cloudera-scm-server

  done
}

main "${@}"
