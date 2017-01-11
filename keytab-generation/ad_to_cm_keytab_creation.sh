#!/bin/bash

LDAP_HOST=$1
LDAP_USER=$2

./ad_account_creation.sh ${LDAP_HOST} ${LDAP_USER}

rm -rf /root/cdh_keytabs
mkdir /root/cdh_keytabs

./ad_keytab_creation.sh
