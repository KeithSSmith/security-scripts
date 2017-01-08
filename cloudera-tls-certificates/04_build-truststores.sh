#!/bin/bash
#keytool -import -alias rootca -storepass ${TRUSTSTORE_PASSWORD} -noprompt -keystore ${CERTIFICATE_DIRECTORY}/jks/truststore.jks -file ${CERTIFICATE_DIRECTORY}/CAcerts/${ROOT_CERTIFICATE};
#ln -s ${DIRECTORY}/jks/truststore.jks /usr/java/default/jre/lib/security/jssecacerts
source tls-functions.sh

main() {
  directory_entry "Enter the base directory (Default: /opt/cloudera/security) to store your certificates and press [ENTER]: " CERTIFICATE_DIRECTORY "/opt/cloudera/security"
  password_entry "Enter a password to be used for the Truststore and press [Enter]: " TRUSTSTORE_PASSWORD
  generic_entry "Enter the Root Certificate name (Ex: RootCA.cer) and press [ENTER]: " ROOT_CERTIFICATE
  pem_for_ssh_check

  HOSTNAME="hostname; "
  TASK_BUILD_TRUSTSTORE="printf 'Importing Root Certificate into each nodes Truststore ...\n'; "
  BUILD_TRUSTSTORE="keytool -import -alias rootca -storepass ${TRUSTSTORE_PASSWORD} -noprompt -keystore ${CERTIFICATE_DIRECTORY}/jks/truststore.jks -file ${CERTIFICATE_DIRECTORY}/CAcerts/${ROOT_CERTIFICATE}; "
  TASK_RM_JSSE="printf 'Removing Truststore symbolic link (if exists) ...\n'; "
  RM_JSSE="rm -f /usr/java/default/jre/lib/security/jssecacerts; "
  TASK_JSSE_SYM_LINK="printf 'Creating Truststore symbolic link into default Java Version ...\n'; "
  JSSE_SYM_LINK="ln -s ${CERTIFICATE_DIRECTORY}/jks/truststore.jks /usr/java/default/jre/lib/security/jssecacerts; "

  SSH_COMMAND="${HOSTNAME}${TASK_BUILD_TRUSTSTORE}${BUILD_TRUSTSTORE}${TASK_RM_JSSE}${RM_JSSE}${TASK_JSSE_SYM_LINK}${JSSE_SYM_LINK}"

  for HOST in $(cat /tmp/hosts)
  do
    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"
  done


  directory_entry "Enter the local directory (Default: /tmp/keytool/pem) to store cluster node's PEM files and press [ENTER]: " PEM_DIRECTORY "/tmp/keytool/pem"

  printf 'Creating directory to transfer all nodes PEM files ...\n'
  mkdir -p ${PEM_DIRECTORY}

  for HOST in $(cat /tmp/hosts)
  do
    printf "Transfering ${HOST} PEM file to local $(hostname -f) node ...\n"
    scp ${PEM_FILE} ${HOST}:${CERTIFICATE_DIRECTORY}/x509/${HOST}.pem ${PEM_DIRECTORY}

    printf "Importing ${HOST} PEM file into Truststore ...\n"
    keytool -keystore ${CERTIFICATE_DIRECTORY}/jks/truststore.jks -importcert -alias ${HOST} -file ${PEM_DIRECTORY}/${HOST}.pem -storepass ${TRUSTSTORE_PASSWORD}
  done
}

main "${@}"
