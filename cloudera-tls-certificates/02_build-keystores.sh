#!/bin/bash
#keytool -importcert -keystore ${DIRECTORY}/jks/node1.keystore -alias RootCA -storepass changeme -keypass changeme -trustcacerts -file /opt/cloudera/security/CAcerts/rootCA.cer
#keytool -importcert -keystore ${DIRECTORY}/jks/node1.keystore -alias node1 -storepass changeme -keypass changeme -trustcacerts -file /opt/cloudera/security/x509/node1.cer
#ln -s /opt/cloudera/security/jks/node1.keystore /opt/cloudera/security/jks/keystore.jks
source tls-functions.sh

MORE_CERTS=true
INTERMEDIATE_CERTS=()

main() {
  directory_entry "Enter the base directory (Default: /opt/cloudera/security) to store your certificates and press [ENTER]: " CERTIFICATE_DIRECTORY "/opt/cloudera/security"
  keystore_file_extenstion "Enter keystore file extension (Default: keystore) and press [Enter]: " KEYSTORE_FILE_EXTENSION
  directory_entry "Enter the Directory where the Signed Certificates are located (Default: /tmp/keytool/certs) and press [ENTER]: " SIGNED_CERTIFICATE_DIRECTORY "/tmp/keytool/certs"
  generic_entry "Enter the Certificate file extension (Ex: cer, cert, pem) and press [ENTER]: " SIGNED_CERTIFICATE_EXTENSION
  generic_entry "Enter the Root Certificate name (Ex: RootCA.cer) and press [ENTER]: " ROOT_CERTIFICATE
  yes_no_entry "Are there any Intermediate Certificates (y/n)? " INTERMEDIATE_EXISTS
  pem_for_ssh_check

  printf 'Transfering Signed Certificates to each node ...\n'

  for HOST in $(cat /tmp/hosts)
  do
    scp ${PEM_FILE} ${SIGNED_CERTIFICATE_DIRECTORY}/${HOST}.${SIGNED_CERTIFICATE_EXTENSION} ${HOST}:${CERTIFICATE_DIRECTORY}/x509/
  done

  printf 'Transfering CA Certificates to each node ...\n'

  for HOST in $(cat /tmp/hosts)
  do
    scp ${PEM_FILE} ${SIGNED_CERTIFICATE_DIRECTORY}/${ROOT_CERTIFICATE} ${HOST}:${CERTIFICATE_DIRECTORY}/CAcerts/
  done

  if ${INTERMEDIATE_EXISTS}
  then

    while ${MORE_CERTS}
    do
      generic_entry "Enter the Intermediate Certificate name (Ex: IntermediateCA.cer) and press [ENTER]: " INTERMEDIATE_CERTIFICATE
      INTERMEDIATE_CERTS+=(${INTERMEDIATE_CERTIFICATE})
      yes_no_entry "Are there any further Intermediate Certificates (y/n)? " MORE_CERTS
    done

    for HOST in $(cat /tmp/hosts)
    do
      for INTERMEDIATE_CERT in $( echo "${INTERMEDIATE_CERTS[@]}" )
      do
        scp ${PEM_FILE} ${SIGNED_CERTIFICATE_DIRECTORY}/${INTERMEDIATE_CERT} ${HOST}:${CERTIFICATE_DIRECTORY}/CAcerts/
      done
    done

  fi

  password_entry "Enter existing password for the Keystore and press [Enter]: " KEYSTORE_PASSWORD

  for HOST in $(cat /tmp/hosts)
  do
    ssh ${PEM_FILE} ${HOST} "hostname; printf 'Importing Root Certificate to keystore ...\n'; keytool -importcert -keystore ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} -alias rootca -storepass ${KEYSTORE_PASSWORD} -keypass ${KEYSTORE_PASSWORD} -trustcacerts -file ${CERTIFICATE_DIRECTORY}/CAcerts/${ROOT_CERTIFICATE}"
    for INTERMEDIATE_CERT in $( echo "${INTERMEDIATE_CERTS[@]}" )
    do
      ssh ${PEM_FILE} ${HOST} "hostname; printf 'Importing Intermedate Certificate ${INTERMEDIATE_CERT} to keystore ...\n'; keytool -importcert -keystore ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} -alias ${INTERMEDIATE_CERT} -storepass ${KEYSTORE_PASSWORD} -keypass ${KEYSTORE_PASSWORD} -trustcacerts -file ${CERTIFICATE_DIRECTORY}/CAcerts/${INTERMEDIATE_CERT}"
    done
    ssh ${PEM_FILE} ${HOST} "hostname; printf 'Importing Signed Certificate ${HOST} to keystore ...\n'; keytool -importcert -keystore ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} -alias ${HOST} -storepass ${KEYSTORE_PASSWORD} -keypass ${KEYSTORE_PASSWORD} -trustcacerts -file ${CERTIFICATE_DIRECTORY}/x509/${HOST}.${SIGNED_CERTIFICATE_EXTENSION}"
  done


  for HOST in $(cat /tmp/hosts)
  do
    ssh ${PEM_FILE} ${HOST} "hostname; printf 'Removing keystore symbolic link (if exists) ...\n'; rm -f ${CERTIFICATE_DIRECTORY}/jks/keystore.jks; printf 'Creating keystore symbolic link ...\n'; ln -s ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} ${CERTIFICATE_DIRECTORY}/jks/keystore.jks"
  done
}

main "${@}"
