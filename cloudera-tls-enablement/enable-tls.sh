#!/bin/bash
source tls-enablement-functions.sh

main() {
  SERVICES="cloudera-navigator hdfs yarn hive hue impala oozie solr spark httpfs"

  generic_entry "Enter the Cloudera Manager hostname that the Cloudera Manager Server is on and press [ENTER]: " CLOUDERA_MANAGER_HOSTNAME
  generic_entry "Enter the Cloudera Manager username and press [ENTER]: " CLOUDERA_MANAGER_USER
  password_entry "Enter the Cloudera Manager password for the user ${CLOUDERA_MANAGER_USER} and press [ENTER]: " CLOUDERA_MANAGER_USER_PASSWORD

  default_entry "Enter the PEM file location to communicate with ${CLOUDERA_MANAGER_HOSTNAME} via TLS (Default: /opt/cloudera/security/x509/cachain.pem) and press [ENTER]: " CLOUDERA_MANAGER_CA_PEM "/opt/cloudera/security/x509/cachain.pem"

  default_entry "Enter the keystore location (Default: /opt/cloudera/security/jks/keystore.jks) and press [ENTER]: " KEYSTORE_PATH "/opt/cloudera/security/jks/keystore.jks"
  password_entry "Enter the keystore password and press [ENTER]: " KEYSTORE_PASSWORD

  default_entry "Enter the truststore location (Default: /usr/java/latest/jre/lib/security/jssecacerts) and press [ENTER]: " TRUSTSTORE_PATH "/usr/java/latest/jre/lib/security/jssecacerts"
  password_entry "Enter the truststore password and press [ENTER]: " TRUSTSTORE_PASSWORD

  default_entry "Enter the location for the CA Certificate in PEM (Base 64) format (Default: /opt/cloudera/security/x509/cachain.pem) and press [ENTER]: " PEM_CA_PATH "/opt/cloudera/security/x509/cachain.pem"
  default_entry "Enter the location for the Host Certifcate in PEM (Base 64) format (Default: /opt/cloudera/security/x509/agent.pem) and press [ENTER]: " PEM_CERT_PATH "/opt/cloudera/security/x509/agent.pem"
  default_entry "Enter the location for the Host Key in PEM (Base 64) format (Default: /opt/cloudera/security/x509/agent.key) and press [ENTER]: " PEM_KEY_PATH "/opt/cloudera/security/x509/agent.key"
  password_entry "Enter the Host Key password and press [ENTER]: " PEM_KEY_PASSWORD


  for SERVICE in ${SERVICES}
  do
    yes_no_entry "Do you want to enable TLS for cluster service ${SERVICE} (y/n)? " ENABLE_TLS

    if ${ENABLE_TLS}
    then
      echo "Starting TLS enablement for ${SERVICE} ..."
      enable-tls-${SERVICE}
      echo "TLS enablement for ${SERVICE} complete!"
    fi
  done

  yes_no_entry "TLS configurations complete for the services selected.  This requires a cluster restart, would you like to proceed (y/n)? " RESTART_CLUSTER
  if ${RESTART_CLUSTER}
  then
    cluster_restart
  else
    echo "Please restart the cluster manually and ensure services start as expected, otherwise communication via TLS will not be enabled."
  fi
}

main "${@}"
