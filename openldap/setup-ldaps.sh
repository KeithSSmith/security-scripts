#!/bin/bash
source openldap-functions.sh

LDAP_CONFIG=$(mktemp -t ldap_config.XXXXXXXXXX)

main() {
  printf 'Changing OpenLDAP properties to use a different CA Certificate Directory ...\n'
  mkdir -p /etc/openldap/cacerts
  cat /etc/openldap/ldap.conf | sed -e 's|TLS_CACERTDIR\t/etc/openldap/certs|#TLS_CACERTDIR\t/etc/openldap/certs\nTLS_CACERTDIR\t/etc/openldap/cacerts|' > ${LDAP_CONFIG}
  cat ${LDAP_CONFIG} > /etc/openldap/ldap.conf

  yes_no_entry "Do you already have the LDAPS Certificate (y/n)? " HAVE_LDAPS_CERT

  if ${HAVE_LDAPS_CERT}
  then
    generic_entry "Please enter the path of the LDAPS Certificate and press [Enter]: " LDAPS_CERTIFICATE_PATH
    printf "Moving ${LDAPS_CERTIFICATE_PATH} to /etc/openldap/cacerts directory ...\n"
    mv ${LDAPS_CERTIFICATE_PATH}
  else
    host_entry "Enter LDAP hostname and press [Enter]: " DOMAIN_CONTROLLER
    printf 'Retrieving LDAPS Certificate from the LDAP Server and placing it in OpenLDAP Certificate Directory ...\n'
    echo -n | openssl s_client -connect ${DOMAIN_CONTROLLER}:636 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/openldap/cacerts/ldaps_cert.pem
  fi

  /usr/sbin/cacertdir_rehash /etc/openldap/cacerts
  rm ${LDAP_CONFIG}
}

main "${@}"
