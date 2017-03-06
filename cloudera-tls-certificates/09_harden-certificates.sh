#!/bin/bash
# Hardening Security Certificates with Linux Extended ACL's
source tls-functions.sh

main() {
  directory_entry "Enter the base directory (Default: /opt/cloudera/security) where certificates are stored and press [ENTER]: " CERTIFICATE_DIRECTORY "/opt/cloudera/security"
  password_entry "Enter existing password for the Truststore and press [Enter]: " TRUSTSTORE_PASSWORD
  pem_for_ssh_check

  for HOST in $(cat /tmp/hosts)
  do
    HOSTNAME="hostname; "
    TASK_CERT_DIR_OWNER="printf 'Changing owner:group for each nodes certificate directory ...\n'; "
    CERT_DIR_OWNER="chown -R root:root ${CERTIFICATE_DIRECTORY}/jks ${CERTIFICATE_DIRECTORY}/CAcerts ${CERTIFICATE_DIRECTORY}/x509; "
    TASK_CERT_DIR_PERMISSIONS="printf 'Changing permissions on each nodes certificate directory ...\n'; "
    CERT_DIR_PERMISSIONS="chmod 755 ${CERTIFICATE_DIRECTORY}/CAcerts ${CERTIFICATE_DIRECTORY}/jks ${CERTIFICATE_DIRECTORY}/x509; "
    TASK_CERT_FILE_PERMISSIONS="printf 'Changing permissions on each nodes certificate files ...\n'; "
    CERT_FILE_PERMISSIONS="chmod 600 ${CERTIFICATE_DIRECTORY}/CAcerts/*.cer ${CERTIFICATE_DIRECTORY}/CAcerts/intermediate.pem ${CERTIFICATE_DIRECTORY}/jks/${HOST}.keystore ${CERTIFICATE_DIRECTORY}/x509/*.csr ${CERTIFICATE_DIRECTORY}/x509/*.cer ${CERTIFICATE_DIRECTORY}/x509/*.pem ${CERTIFICATE_DIRECTORY}/x509/*.key; chmod 644 ${CERTIFICATE_DIRECTORY}/CAcerts/root.pem ${CERTIFICATE_DIRECTORY}/x509/root_and_intermediate.pem ${CERTIFICATE_DIRECTORY}/jks/truststore.jks; "

    SSH_COMMAND=${HOSTNAME}${TASK_CERT_DIR_OWNER}${CERT_DIR_OWNER}${TASK_CERT_DIR_PERMISSIONS}${CERT_DIR_PERMISSIONS}${TASK_CERT_FILE_PERMISSIONS}${CERT_FILE_PERMISSIONS}

    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"


    EDH_USERS="cloudera-scm flume hbase hdfs hive httpfs hue impala kafka keytrustee kms kudu mapred oozie solr spark sqoop sqoop2 yarn zookeeper"
    for EDH_USER in ${EDH_USERS}
    do
      HOSTNAME="hostname; "
      TASK_FACL_TRUSTSTORE="printf 'Setting Linux extended ACL for read permissions on the truststore ...\n'; "
      FACL_TRUSTSTORE="setfacl -m \"u:${EDH_USER}:r-\" ${CERTIFICATE_DIRECTORY}/jks/truststore.jks; "
      TASK_FACL_KEYSTORE="printf 'Setting Linux extended ACL for read permissions on the keystore ...\n'; "
      FACL_KEYSTORE="setfacl -m \"u:${EDH_USER}:r-\" ${CERTIFICATE_DIRECTORY}/jks/${HOST}.keystore; "
      TASK_FACL_PEM_KEY="printf 'Setting Linux extended ACL for read permissions on the PEM (base 64) key ...\n'; "
      FACL_PEM_KEY="setfacl -m \"u:${EDH_USER}:r-\" ${CERTIFICATE_DIRECTORY}/x509/${HOST}.key; "
      TASK_FACL_PEM_CERT="printf 'Setting Linux extended ACL for read permissions on the PEM (base 64) certificate ...\n'; "
      FACL_PEM_CERT="setfacl -m \"u:${EDH_USER}:r-\" ${CERTIFICATE_DIRECTORY}/x509/${HOST}.pem; "
      SSH_COMMAND${HOSTNAME}${TASK_FACL_TRUSTSTORE}${FACL_TRUSTSTORE}${TASK_FACL_KEYSTORE}${FACL_KEYSTORE}${TASK_FACL_PEM_KEY}${FACL_PEM_KEY}${TASK_FACL_PEM_CERT}${FACL_PEM_CERT}

      ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"
    done
  done
}

main "${@}"
