#!/bin/bash

#Utility to search for Kerberos Service Principals in Active Directory and echo out an LDAP Delete command to delete the user based on the Distinguished Name.
#Example of searching for a Service Principal, which returns a list of results, one of which is the distinguishedName.
#The distinguishedName is then passed to the ldapdelete command for verification, the ldapdelete output should be run manually.
#ldapsearch -LLL -H ldaps://[LDAP FQDN]:636 -b ou=Hadoop,DC=example,DC=com userPrincipalName=HTTP/ip-10-0-0-1.ec2.internal@EXAMPLE.COM
#ldapdelete -h [LDAP FQDN] -p 636 "cn=hdfs,ou=Hadoop,DC=example,DC=com"

source openldap-functions.sh

main() {
  if [[ -z "${@}" ]]
  then
    host_entry "What is the hostname of the LDAPS server you are wanting to query? " LDAP_HOST
    generic_entry "What is the bind location to searche the LDAP directory? " LDAP_BIND
    generic_entry "What service (Ex: hdfs) are you wanting to find and delete? " SERVICES
    host_entry "What node(s) are ${LDAP_SERVICE} running on that you want to remove? " HADOOP_HOST
    generic_entry "What is the domain (Ex: EXAMPLE.COM) of the cluster? " HADOOP_DOMAIN
    HOSTS="${HADOOP_HOST}@${HADOOP_DOMAIN}"
  else
    LDAP_HOST=${1^^}     #Example: LDAPHOST1.EXAMPLE.COM
    LDAP_BIND=${2}       #Example: ou=Hadoop,DC=example,DC=com
    SERVICES=${3}        #List of services that have Kerberos keytabs: "HTTP hdfs hive httpfs hue impala mapred oozie solr spark yarn zookeeper"
    HOSTS=${4}           #Host list space delimited with Capital Kerberos Security Realm: "ip-10-0-0-1.ec2.internal@EXAMPLE.COM ip-10-0-0-2.ec2.internal@EXAMPLE.COM"
  fi

  for SERVICE in ${SERVICES}
  do
    for HOST in ${HOSTS}
    do
      PRINC_NAME=${SERVICE}/${HOST}
      LDAP_SEARCH="ldapsearch -LLL -H ldaps://${LDAP_HOST}:636 -b ${LDAP_BIND} userPrincipalName=${PRINC_NAME}"
      DISTINGUISHED_NAME=$( ${LDAP_SEARCH} 2> /dev/null | grep distinguishedName | awk '{print $2}' )

      if [ ! -z ${DISTINGUISHED_NAME} ]
      then
        echo ldapdelete -h ${LDAP_HOST} -p 636 "${DISTINGUISHED_NAME}"
      fi
    done
  done
}

main "${@}"
