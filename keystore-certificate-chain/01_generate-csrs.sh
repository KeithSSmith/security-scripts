#!/bin/bash
#keytool -genkeypair -keystore ${DIRECTORY}/jks/node1.keystore -alias node1 -dname "CN=node1.example.com,O=Hadoop" -keyalg RSA -keysize 2048 -storepass changeme -keypass changeme
#keytool -certreq -keystore ${DIRECTORY}/jks/node1.keystore -alias node1 -storepass changeme -keypass changeme -file ${DIRECTORY}/x509/node1.csr
#Check CSR’s: https://cryptoreport.websecurity.symantec.com/checker/views/csrCheck.jsp
source tls-functions.sh

main() {
  directory_entry "Enter the base directory (Default: /opt/cloudera/security) to store your certificates and press [ENTER]: " CERTIFICATE_DIRECTORY "/opt/cloudera/security"
  create_certificate_directory "${CERTIFICATE_DIRECTORY}"
  keystore_file_extenstion "Enter keystore file extension (Default: keystore) and press [Enter]: " KEYSTORE_FILE_EXTENSION
  #host_entry "Enter domain name to trust in subject alternative name and press [ENTER]: " DOMAIN
  password_entry "Enter password for keystore and press [Enter]: " KEYSTORE_PASSWORD
  distinguished_name_entry DISTINGUISHED_NAME
  pem_for_ssh_check

  for HOST in $(cat /tmp/hosts)
  do
    ssh ${PEM_FILE} ${HOST} "hostname; ${REMOVE_EXISTING_KEYSTORE} printf 'Creating keystore...\n'; keytool -genkeypair -keystore ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} -alias ${HOST} -dname \"CN=${HOST},${DISTINGUISHED_NAME}\" -ext san=dns:${HOST} -keyalg RSA -keysize 2048 -storepass ${KEYSTORE_PASSWORD} -keypass ${KEYSTORE_PASSWORD}; printf 'Generating CSR...\n'; keytool -certreq -alias ${HOST} -keystore ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} -file ${CERTIFICATE_DIRECTORY}/x509/${HOST}.csr -ext san=dns:${HOST} -storepass ${KEYSTORE_PASSWORD} -keypass ${KEYSTORE_PASSWORD}"
  done

  collect_csrs "/tmp/keytool/csr"
}

main "${@}"
