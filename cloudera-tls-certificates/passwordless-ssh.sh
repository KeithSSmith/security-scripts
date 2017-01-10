#!/bin/bash
#Enable TLS for Cloudera Manager Server
#http://www.cloudera.com/documentation/enterprise/latest/topics/cm_sg_tls_browser.html
source tls-functions.sh

main() {
  ssh-keygen -t rsa

  for HOST in $(cat /tmp/hosts)
  do
    ssh-copy-id root@"${HOST}"
  done
}

main "${@}"
