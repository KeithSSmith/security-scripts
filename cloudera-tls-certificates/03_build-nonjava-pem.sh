#!/bin/bash
#keytool -importkeystore -srckeystore ${DIRECTORY}/jks/node1.jks -srcstorepass changeme -srckeypass changeme -destkeystore /tmp/keystore.p12 -deststoretype PKCS12 -srcalias ${HOST} -deststorepass changeme -destkeypass changeme
#openssl pkcs12 -in /tmp/keystore.p12 -passin pass:changeme -nokeys -out ${DIRECTORY}/x509/node1.pem
#openssl pkcs12 -in /tmp/keystore.p12 -passin pass:changeme -nokeys -out ${DIRECTORY}/x509/noe1.pem
#ln -s ${DIRECTORY}/x509/node1.key ${DIRECTORY}/x509/cmagent.key
#ln -s ${DIRECTORY}/x509/node1.pem ${DIRECTORY}/x509/cmagent.pem
source tls-functions.sh

main() {
  directory_entry "Enter the base directory (Default: /opt/cloudera/security) to store your certificates and press [ENTER]: " CERTIFICATE_DIRECTORY "/opt/cloudera/security"
  password_entry "Enter exiting password for the Keystore and press [Enter]: " KEYSTORE_PASSWORD
  pem_for_ssh_check

  for HOST in $(cat /tmp/hosts)
  do
    HOSTNAME="hostname; "
    TASK_BUILD_PKCS12="printf 'Transforming keystore to PKCS12 format ...\n'; "
    KEYTOOL_PKCS12="keytool -importkeystore -srckeystore ${CERTIFICATE_DIRECTORY}/jks/keystore.jks -srcstorepass ${KEYSTORE_PASSWORD} -srckeypass ${KEYSTORE_PASSWORD} -destkeystore /tmp/keystore.p12 -deststoretype PKCS12 -srcalias ${HOST} -deststorepass ${KEYSTORE_PASSWORD} -destkeypass ${KEYSTORE_PASSWORD}; "
    TASK_BUILD_CERT="printf 'Extracting certificate from PKCS12 ...\n'; "
    OPENSSL_CERT="openssl pkcs12 -in /tmp/keystore.p12 -passin pass:${KEYSTORE_PASSWORD} -nokeys -out ${CERTIFICATE_DIRECTORY}/x509/${HOST}.pem; "
    TASK_BUILD_KEY="printf 'Extracting key from PKCS12 ...\n'; "
    OPENSSL_KEY="openssl pkcs12 -in /tmp/keystore.p12 -passin pass:${KEYSTORE_PASSWORD} -nocerts -out ${CERTIFICATE_DIRECTORY}/x509/${HOST}.key -passout pass:${KEYSTORE_PASSWORD}; "
    TASK_REMOVE_CERT_LINK="printf 'Removing certificate symbolic link (if exists) ...\n'; "
    SYMBOLIC_LINK_RM_CERT="rm -f ${CERTIFICATE_DIRECTORY}/x509/cmagent.pem; "
    TASK_ADD_CERT_LINK="printf 'Adding certificate symbolic link ...\n'; "
    SYMBOLIC_LINK_CERT="ln -s ${CERTIFICATE_DIRECTORY}/x509/${HOST}.pem ${CERTIFICATE_DIRECTORY}/x509/cmagent.pem; "
    TASK_REMOVE_KEY_LINK="printf 'Removing key symbolic link (if exists) ...\n'; "
    SYMBOLIC_LINK_RM_KEY="rm -f ${CERTIFICATE_DIRECTORY}/x509/cmagent.key; "
    TASK_ADD_KEY_LINK="printf 'Adding key symbolic link ...\n'; "
    SYMBOLIC_LINK_KEY="ln -s ${CERTIFICATE_DIRECTORY}/x509/${HOST}.key ${CERTIFICATE_DIRECTORY}/x509/cmagent.key; "
    TASK_REMOVE_PKCS12="printf 'Removing temporary PKCS12 file ...\n'; "
    PKCS12_REMOVE="rm -f /tmp/keystore.p12; "

    SSH_COMMAND="${HOSTNAME}${TASK_BUILD_PKCS12}${KEYTOOL_PKCS12}${TASK_BUILD_CERT}${OPENSSL_CERT}${TASK_BUILD_KEY}${OPENSSL_KEY}${TASK_REMOVE_CERT_LINK}${SYMBOLIC_LINK_RM_CERT}${TASK_ADD_CERT_LINK}${SYMBOLIC_LINK_CERT}${TASK_REMOVE_KEY_LINK}${SYMBOLIC_LINK_RM_KEY}${TASK_ADD_KEY_LINK}${SYMBOLIC_LINK_KEY}${TASK_REMOVE_PKCS12}${PKCS12_REMOVE}"

    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"
  done
}

main "${@}"
