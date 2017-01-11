#!/bin/bash

LDAP_HOST=$1
LDAP_USER=$2

while read input
do

  ACCT_NAME=$(echo ${input} | awk '{print $1}')
  SPN=$(echo ${input} | awk '{print $2}')
  UPN=$(echo ${input} | awk '{print $3}')
  DN=$(echo ${input} | awk '{print $4}')
  PASS=$(echo -n "\"Example 123!\"" | iconv -f UTF8 -t UTF16LE| base64 -w 0)

ldapmodify -H ldaps://${LDAP_HOST} -x -D ${LDAP_USER} -W <<-%EOF
dn: ${DN}
changetype: add
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
distinguishedName: ${DN}
sAMAccountName: ${ACCT_NAME}
servicePrincipalName: ${SPN}
userPrincipalName: ${UPN}
unicodePwd:: ${PASS}
accountExpires: 0
userAccountControl: 66048
%EOF

done < ad_accounts.txt
