#!/bin/bash
source openldap-functions.sh

main() {
  if [[ -z "${@}" ]]
  then
    host_entry "What is the hostname of the LDAPS server you are wanting to query? " LDAP_HOST
    generic_entry "What is the bind location to search the LDAP directory? " LDAP_BIND
    generic_entry "What account are you wanting to search for? " ACCOUNT_NAME
  else
    LDAP_HOST=${1^^}     #Example: LDAPHOST1.EXAMPLE.COM
    LDAP_BIND=${2}       #Example: ou=Users,DC=example,DC=com
    ACCOUNT_NAME=${3}       #The User Name to search for under the Bind Location.
  fi

  yes_no_entry "Are you searching over secure LDAPS (y/n)? " LDAPS_FLAG
  yes_no_entry "Are you Authenticated via Kerberos (y/n)? " KERBEROS_FLAG

  if ${LDAPS_FLAG}
  then
    if ${KERBEROS_FLAG}
    then
      LDAP_SEARCH="ldapsearch -LLL -H ldaps://${LDAP_HOST}:636 -b ${LDAP_BIND} sAMAccountName=${ACCOUNT_NAME}"
    else
      generic_entry "What is the Distinguished Name (Ex: cn=admin,dc=example,dc=com) to Authenticate against the LDAP directory? " LDAP_DISTINGUISHED_NAME
      LDAP_SEARCH="ldapsearch -D "${LDAP_DISTINGUISHED_NAME}" -W -LLL -H ldaps://${LDAP_HOST}:636 -b ${LDAP_BIND} sAMAccountName=${ACCOUNT_NAME}"
    fi
  else
    if ${KERBEROS_FLAG}
    then
      LDAP_SEARCH="ldapsearch -LLL -H ldap://${LDAP_HOST}:389 -b ${LDAP_BIND} sAMAccountName=${ACCOUNT_NAME}"
    else
      generic_entry "What is the Distinguished Name (Ex: cn=admin,dc=example,dc=com) to Authenticate against the LDAP directory? " LDAP_DISTINGUISHED_NAME
      LDAP_SEARCH="ldapsearch -D "${LDAP_DISTINGUISHED_NAME}" -W -LLL -H ldap://${LDAP_HOST}:389 -b ${LDAP_BIND} sAMAccountName=${ACCOUNT_NAME}"
    fi
  fi

  eval "${LDAP_SEARCH}"
}

main "${@}"
