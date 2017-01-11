#!/bin/bash
# Custom Kerberos Keytab Retrieval Script
# This script is called by Cloudera Manager Server. It takes two arguments:
#   A destination file to write the key to, and
#   The full principal name to retrieve the keytab for

# CM will input /tmp for DEST
DEST=$1

# CM will input principal name in format <service>/<fqdn>@REALM
PRINC=$2

# BASEDIR is the location on Cloudera Manager Server host where the keytabs are stored
# BASEDIR=/etc/cloudera-scm-server/service_keytabs
BASEDIR=/root/cdh_keytabs

# Parse PRINC to determine keytab filename
SERV=${PRINC%%/*}
NORM=${PRINC%%@*}
NORM_LOWER=${NORM,,}
FQDN=${NORM_LOWER#*/}
#FQDN=${NORM#*/}

# Keytab filenames should be in format <service>_<fqdn>.keytab
FILE=${BASEDIR}/${SERV}_${FQDN}.keytab
echo ${FILE}

if [ ! -e ${FILE} ] ; then
  # Keytab not found
  echo "Keytab not found: ${FILE}"
  echo "Keytab not found: ${FILE}" > ${BASEDIR}/error.log
  exit 1
fi

cp ${FILE} ${DEST}
exit 0
