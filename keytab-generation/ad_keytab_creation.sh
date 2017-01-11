#!/bin/bash

while read input
do

  SPN=$(echo ${input} | awk '{print $2}')
  SERV=${SPN%%/*}
  NORM=${SPN%%@*}
  NORM_HOST=$(echo ${NORM^^} | awk -F'.' '{print $1}' | awk -F'/' '{print $2}')
  NORM_UPPER=$(echo ${NORM} | sed -e "s/${NORM_HOST,,}/${NORM_HOST}/")
  FQDN=${NORM#*/}
  KVNO=$(kvno ${NORM} | sed -e 's/^.*= //')

  IFS=' ' read -a ENC_ARR <<< "arcfour-hmac"
  {
    for ENC in "${ENC_ARR[@]}"
    do
      echo "addent -password -p ${NORM} -k ${KVNO} -e ${ENC}"
      echo "Cloudera 123#"
      echo "addent -password -p ${NORM_UPPER} -k ${KVNO} -e ${ENC}"
      echo "Cloudera 123#"
    done
    echo "wkt /root/cdh_keytabs/${SERV}_${FQDN}.keytab"
  } | ktutil

done < ad_accounts.txt
