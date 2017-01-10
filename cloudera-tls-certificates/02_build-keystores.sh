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
  HOSTNAME="hostname; "

  for HOST in $(cat /tmp/hosts)
  do
    TASK_IMPORT_ROOT_CERT="printf 'Importing Root Certificate to keystore ...\n'; "
    IMPORT_ROOT_CERT="keytool -importcert -keystore ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} -alias rootca -storepass ${KEYSTORE_PASSWORD} -keypass ${KEYSTORE_PASSWORD} -trustcacerts -file ${CERTIFICATE_DIRECTORY}/CAcerts/${ROOT_CERTIFICATE}; "
    TASK_IMPORT_ROOT_CERT_CACHAIN="printf 'Importing Root Certificate into Base 64 Certificate Chain ...\n'; "
    IMPORT_ROOT_CERT_CACHAIN="cat ${CERTIFICATE_DIRECTORY}/CAcerts/${ROOT_CERTIFICATE} > ${CERTIFICATE_DIRECTORY}/CAcerts/cachain.pem; "

    SSH_COMMAND="${HOSTNAME}${TASK_IMPORT_ROOT_CERT}${IMPORT_ROOT_CERT}${TASK_IMPORT_ROOT_CERT_CACHAIN}${IMPORT_ROOT_CERT_CACHAIN}"

    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"

    for INTERMEDIATE_CERT in $( echo "${INTERMEDIATE_CERTS[@]}" )
    do
      TASK_IMPORT_INT_CERT="printf 'Importing Intermediate Certificate ${INTERMEDIATE_CERT} to keystore ...\n'; "
      IMPORT_INT_CERT="keytool -importcert -keystore ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} -alias ${INTERMEDIATE_CERT} -storepass ${KEYSTORE_PASSWORD} -keypass ${KEYSTORE_PASSWORD} -trustcacerts -file ${CERTIFICATE_DIRECTORY}/CAcerts/${INTERMEDIATE_CERT}; "
      TASK_IMPORT_INT_CERT_CACHAIN="printf 'Importing Intermediate Certificate into Base 64 Certificate Chain ...\n'; "
      IMPORT_INT_CERT_CACHAIN="cat ${CERTIFICATE_DIRECTORY}/CAcerts/${INTERMEDIATE_CERT} >> ${CERTIFICATE_DIRECTORY}/CAcerts/cachain.pem; "

      SSH_COMMAND="${HOSTNAME}${TASK_IMPORT_INT_CERT}${IMPORT_INT_CERT}${TASK_IMPORT_INT_CERT_CACHAIN}${IMPORT_INT_CERT_CACHAIN}"

      ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"
    done

    TASK_IMPORT_HOST_CERT="printf 'Importing Signed Certificate ${HOST} to keystore ...\n'; "
    IMPORT_HOST_CERT="keytool -importcert -keystore ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} -alias ${HOST} -storepass ${KEYSTORE_PASSWORD} -keypass ${KEYSTORE_PASSWORD} -trustcacerts -file ${CERTIFICATE_DIRECTORY}/x509/${HOST}.${SIGNED_CERTIFICATE_EXTENSION}; "

    SSH_COMMAND="${HOSTNAME}${TASK_IMPORT_HOST_CERT}${IMPORT_HOST_CERT}"

    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"
  done


  for HOST in $(cat /tmp/hosts)
  do
    TASK_REMOVE_KEYSTORE_SYM_LINK="printf 'Removing keystore symbolic link (if exists) ...\n'; "
    REMOVE_KEYSTORE_SYM_LINK="rm -f ${CERTIFICATE_DIRECTORY}/jks/keystore.jks; "
    TASK_CREATE_KEYSTORE_SYM_LINK="printf 'Creating keystore symbolic link ...\n'; "
    CREATE_KEYSTORE_SYM_LINK="ln -s ${CERTIFICATE_DIRECTORY}/jks/${HOST}.${KEYSTORE_FILE_EXTENSION} ${CERTIFICATE_DIRECTORY}/jks/keystore.jks; "

    SSH_COMMAND="${HOSTNAME}${TASK_REMOVE_KEYSTORE_SYM_LINK}${REMOVE_KEYSTORE_SYM_LINK}${TASK_CREATE_KEYSTORE_SYM_LINK}${CREATE_KEYSTORE_SYM_LINK}"

    ssh ${PEM_FILE} ${HOST} "${SSH_COMMAND}"
  done
}

main "${@}"
