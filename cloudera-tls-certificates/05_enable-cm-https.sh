#!/bin/bash
#keytool -import -alias rootca -storepass ${TRUSTSTORE_PASSWORD} -noprompt -keystore ${CERTIFICATE_DIRECTORY}/jks/truststore.jks -file ${CERTIFICATE_DIRECTORY}/CAcerts/${ROOT_CERTIFICATE};
#ln -s ${DIRECTORY}/jks/truststore.jks /usr/java/default/jre/lib/security/jssecacerts
source tls-functions.sh

main() {
  directory_entry "Enter the base directory (Default: /opt/cloudera/security) to store your certificates and press [ENTER]: " CERTIFICATE_DIRECTORY "/opt/cloudera/security"
  password_entry "Enter existing password for the Keystore and press [Enter]: " KEYSTORE_PASSWORD
  password_entry "Enter existing password for the Truststore and press [Enter]: " TRUSTSTORE_PASSWORD
  generic_entry "Enter the Cloudera Manager hostname that the Cloudera Manager Server is on and press [ENTER]: " CLOUDERA_MANAGER_HOSTNAME
  generic_entry "Enter the Cloudera Manager Server Admin username and press [ENTER]: " CLOUDERA_MANAGER_USER

  printf 'Enabling TLS for Cloudera Manager Server ...\n'
  curl -X PUT -u ${CLOUDERA_MANAGER_USER} -i \
  -H "content-type:application/json" \
  -d '{ "items" :
        [
          {"name" : "WEB_TLS", "value" : "true"},
          {"name" : "KEYSTORE_PATH", "value" : "'${CERTIFICATE_DIRECTORY}'/jks/keystore.jks"},
          {"name" : "KEYSTORE_PASSWORD", "value" : "'${KEYSTORE_PASSWORD}'"}
        ]
      }' http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/v13/cm/config

  printf '\nEnabling TLS for Cloudera Management Services ...\n'
  curl -X PUT -u ${CLOUDERA_MANAGER_USER} -i \
  -H "content-type:application/json" \
  -d '{ "items" :
        [
          {"name" : "ssl_client_truststore_location", "value" : "/usr/java/default/jre/lib/security/jssecacerts"},
          {"name" : "ssl_client_truststore_password", "value" : "'${TRUSTSTORE_PASSWORD}'"}
        ]
      }' http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/v13/cm/service/config

  printf '\nRestarting Cloudera Management Services ...\n'
  curl -X POST -u ${CLOUDERA_MANAGER_USER} http://${CLOUDERA_MANAGER_HOSTNAME}:7180/api/v13/cm/service/commands/restart

  printf '\n'
  pem_for_ssh_check
  for HOST in $(cat /tmp/hosts)
  do
    ssh ${PEM_FILE} ${HOST} "hostname; printf 'Restarting Cloudera Manager Agent on ${HOST} ...\n'; systemctl restart cloudera-scm-agent"
  done

  printf 'Restarting Cloudera Manager Server, the new Cloudera Manager Port will be 7183 ...\n'
  systemctl restart cloudera-scm-server
}

main "${@}"
