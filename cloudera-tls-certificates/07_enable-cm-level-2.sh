#!/bin/bash
#Enable TLS for Cloudera Manager Server
#http://www.cloudera.com/documentation/enterprise/latest/topics/cm_sg_tls_browser.html
source tls-functions.sh

main() {
  directory_entry "Enter the base directory (Default: /opt/cloudera/security) where certificates are stored and press [ENTER]: " CERTIFICATE_DIRECTORY "/opt/cloudera/security"
  generic_entry "Enter the Cloudera Manager hostname that the Cloudera Manager Server is on and press [ENTER]: " CLOUDERA_MANAGER_HOSTNAME
  generic_entry "Enter the Cloudera Manager Server Admin username and press [ENTER]: " CLOUDERA_MANAGER_USER
  pem_for_ssh_check

  for HOST in $(cat /tmp/hosts)
  do
    HOSTNAME="hostname; "
    TASK_CM_AGENT_CONFIG="printf 'Making a backup of the original Cloudera Manager Agents config.ini ...\n'; "
    CM_AGENT_CONFIG="cat /etc/cloudera-scm-agent/config.ini.level-1 | sed \"s|# verify_cert_dir=|verify_cert_dir=${CERTIFICATE_DIRECTORY}/CAcerts|\" > /etc/cloudera-scm-agent/config.ini.level-2; "
    TASK_CP_AGENT_CONFIG="printf 'Enabling TLS Level 2 for Cloudera Manager Agents config.ini ...\n'; "
    CP_AGENT_CONFIG="cp /etc/cloudera-scm-agent/config.ini.level-2 /etc/cloudera-scm-agent/config.ini; "
    TASK_REHASH_CACERT_DIR="printf 'Rehashing the CA Certificate directory to ensure TLS Level 2 for Cloudera Manager Agents resolve ...\n'; "
    REHASH_CACERT_DIR="/usr/sbin/cacertdir_rehash ${CERTIFICATE_DIRECTORY}/CAcerts/; "
    TASK_RESTART_CM_AGENT="printf 'Restarting the Cloudera Manager Agents to enable TLS Level 2 ...\n'; "
    RESTART_CM_AGENT="systemctl restart cloudera-scm-agent; "

    SSH_COMMAND="${HOSTNAME}${TASK_CM_AGENT_CONFIG}${CM_AGENT_CONFIG}${TASK_CP_AGENT_CONFIG}${CP_AGENT_CONFIG}${TASK_REHASH_CACERT_DIR}${REHASH_CACERT_DIR}${TASK_RESTART_CM_AGENT}${RESTART_CM_AGENT}"

    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"
  done

  printf '\nRestarting Cloudera Management Services ...\n'
  curl -X POST -u ${CLOUDERA_MANAGER_USER} --cacert "${CERTIFICATE_DIRECTORY}/CAcerts/cachain.pem" https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v13/cm/service/commands/restart
}

main "${@}"
