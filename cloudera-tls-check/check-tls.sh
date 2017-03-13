#!/bin/bash
source tls-check-functions.sh

main() {
  SERVICES="cloudera-manager cloudera-navigator hdfs yarn hive hue impala oozie solr spark httpfs"
  SERVICES="cloudera-navigator"

  generic_entry "Enter the Cloudera Manager hostname that the Cloudera Manager Server is on and press [ENTER]: " CLOUDERA_MANAGER_HOSTNAME
  generic_entry "Enter the Cloudera Manager username and press [ENTER]: " CLOUDERA_MANAGER_USER
  password_entry "Enter the Cloudera Manager password for the user ${CLOUDERA_MANAGER_USER} and press [ENTER]: " CLOUDERA_MANAGER_USER_PASSWORD

  default_entry "Enter the PEM file location to communicate with ${CLOUDERA_MANAGER_HOSTNAME} via TLS (Default: /opt/cloudera/security/x509/cachain.pem) and press [ENTER]: " CLOUDERA_MANAGER_CA_PEM "/opt/cloudera/security/x509/cachain.pem"
  # check_cloudera_manager_version
  # check_cloudera_manager_cluster_name


  for SERVICE in ${SERVICES}
  do
    yes_no_entry "Do you want to check if TLS is enabled for cluster service ${SERVICE} (y/n)? " CHECK_TLS

    if ${CHECK_TLS}
    then
      source check-tls-${SERVICE}.sh
      check-tls-${SERVICE}
    fi
  done
}

main "${@}"
