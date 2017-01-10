#!/bin/bash
source tls-functions.sh

MORE_HOSTS=true
HOSTS=()
HOST_LIST=$(mktemp -t all_host.XXXXXXXXXX)

main() {
  host_entry "Enter domain name (Ex: example.com) and press [ENTER]: " DOMAIN

  while ${MORE_HOSTS}
  do

    host_entry "Enter host pattern (Ex: cdh-) and press [Enter]: " HOST_PATTERN
    host_entry "What number do the hosts of type \"${HOST_PATTERN}\" start with (Ex: 1 or 01 or 0001)? " HOST_NUMBER_START
    host_entry "What number do the hosts of type \"${HOST_PATTERN}\" end with (Ex: 9 or 31 or 0041)? " HOST_NUMBER_END
    check_number ${HOST_NUMBER_START} ${HOST_NUMBER_END}
    generate_fqdn ${HOST_PATTERN} ${START} ${END} ${DOMAIN,,} HOSTS
    yes_no_entry "Write the above list of hosts to the hosts file (y/n)? " WRITE_HOSTS
    write_hosts ${WRITE_HOSTS}
    yes_no_entry "Would you like to include any other hosts in this list (y/n)? " ADD_HOSTS
    more_hosts ${ADD_HOSTS}

  done

  cat ${HOST_LIST} > /tmp/hosts
  rm ${HOST_LIST}
}

main "${@}"
