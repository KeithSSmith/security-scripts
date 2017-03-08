#!/bin/bash
set -e
PEM_FILE=''
declare -A TRUTH_ARRAY=( ["y"]=true ["yes"]=true ["t"]=true ["true"]=true ["n"]=false ["no"]=false ["f"]=false ["false"]=false )
declare -A VERSION_ARRAY=( ["5.11"]="v16" ["5.10"]="v15" ["5.9"]="v14" ["5.8"]="v13" ["5.7"]="v12" ["5.6"]="v11" ["5.5"]="v11" )
source enable-tls-cloudera-navigator.sh
source enable-tls-hdfs.sh
source enable-tls-yarn.sh
source enable-tls-hive.sh
source enable-tls-hue.sh
source enable-tls-impala.sh
source enable-tls-oozie.sh
source enable-tls-solr.sh
source enable-tls-httpfs.sh
source enable-tls-spark.sh
source enable-tls-restart.sh


parameter_count_check() {
  if [[ "${1}" -ne "${2}" ]]
  then
    echo "Invalid number of parameters present for ${0} function call."
    exit 1
  fi
}

generic_read() {
  parameter_count_check "$#" 1
  PROMPT=${1}
  read -r -p "${PROMPT}" ENTRY
}

generic_entry() {
  parameter_count_check "$#" 2
  generic_read "${1}"

  if [[ -z ${ENTRY} ]]
  then
    echo -n "No value entered, retrying..."
    generic_entry "${PROMPT}" ${2}
  else
    eval "${2}=\"${ENTRY}\""
  fi
}

password_entry() {
  parameter_count_check "$#" 2

  read -s -r -p "${1}" PASSWORD

  if [[ -z ${PASSWORD} ]]
  then
    printf "No value entered, retrying...\n"
    password_entry "${1}" "${2}"
  else
    printf "\n"
  fi

  eval "${2}=\"${PASSWORD}\""
}

variable_fqdn_check() {
  parameter_count_check "$#" 1

  if [[ "${1}" =~ ^[a-z0-9\.\-]*$ ]]
  then
    return $?
  else
    return $?
  fi
}

host_entry() {
  parameter_count_check "$#" 2
  generic_read "${1}"

  if [[ -z ${ENTRY} ]]
  then
    echo -n "No value entered, retrying..."
    host_entry "${PROMPT}" ${2}
  elif ! $( variable_fqdn_check "${ENTRY}" )
  then
    echo -n "User entered a value containing a disallowed value; Allowed values include lowercase letters, numbers, periods, or hyphens. "
    host_entry "${PROMPT}" ${2}
  else
    eval "${2}=\"${ENTRY}\""
  fi
}

yes_no_entry() {
  parameter_count_check "$#" 2
  unset ENTRY
  generic_read "${1}"

  while [[ -z ${ENTRY} ]] || [[ -z ${TRUTH_ARRAY[${ENTRY,,}]} ]]
  do
    echo -n "Please enter a valid yes or no response (y/n): "
    yes_no_entry "${PROMPT}" ${2}
  done

  eval "${2}=${TRUTH_ARRAY[${ENTRY,,}]}"
}

default_entry() {
  parameter_count_check "$#" 3
  generic_read "${1}"

  if [[ -z ${ENTRY} ]]
  then
    yes_no_entry "No value entered, use default value: '${3}' (y/n)? " USE_DEFAULT_OPTION

    if ${USE_DEFAULT_OPTION}
    then
      eval "${2}=${3}"
    else
      default_entry "${1}" "${2}" "${3}"
    fi

  else
    eval "${2}=\"${ENTRY}\""
  fi
}

pem_for_ssh_check() {
  parameter_count_check "$#" 0

  if [[ -z ${PEM_FILE} ]]
  then
    yes_no_entry "Is a PEM file required for SSH access (y/n): " PEM_REQUIRED

    if ${PEM_REQUIRED}
    then

      while [[ -z ${PEM_ENTRY} ]]
      do
        read -r -p "Enter PEM file location: " PEM_ENTRY
      done

      PEM_FILE="-i ${PEM_ENTRY}"

    else
      unset PEM_FILE
    fi
  fi
}

check_cloudera_manager_version() {
  parameter_count_check "$#" 0

  CM_VERSION_API=$(mktemp -t cm_version.XXXXXXXXXX)

  curl -s -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v1/cm/version > "${CM_VERSION_API}"

  CM_VERSION=$(cat "${CM_VERSION_API}" | grep version | awk -F':' '{print $2}' | sed -e 's| "||' -e 's|",||' | awk -F'.' '{print $1 "." $2}')
  CM_MAJOR_VERSION=$(echo "${CM_VERSION}" | awk -F'.' '{print $1}')
  CM_MINOR_VERSION=$(echo "${CM_VERSION}" | awk -F'.' '{print $2}')


  if [[ ${CM_MAJOR_VERSION} -eq 5 ]]
  then
    if [[ ${CM_MINOR_VERSION} -ge 5 ]]
    then
      echo "Cloudera Manager version - ${CM_VERSION} will use Cloudera Manager API version - ${VERSION_ARRAY[${CM_VERSION}]}"
      CM_API_VERSION="${VERSION_ARRAY[${CM_VERSION}]}"
    else
      echo "Unsupported Cloudera Manager version (${CM_VERSION}), please upgrade to 5.5 or higher."
      exit 1
    fi
  elif [[ ${CM_MAJOR_VERSION} -ge 6 ]]
  then
    echo "Cloudera Manager version greater than 5, defaulting CM API version to v15"
    CM_API_VERSION="v15"
  else
    echo "Unsupported Cloudera Manager version (${CM_VERSION}), please upgrade to 5.5 or higher."
    exit 1
  fi

  rm -f ${CM_VERSION_API}
}

check_cloudera_manager_cluster_name() {
  parameter_count_check "$#" 0

  CM_CLUSTERS_API=$(mktemp -t cm_clusters.XXXXXXXXXX)

  curl -s -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/v11/cm/version > "${CM_CLUSTERS_API}"

  CLUSTERS=$(cat ${CM_CLUSTERS_API} | grep name | awk -F':' '{print $2}' | sed -e 's| "||' -e 's|",||')
  CLUSTERS_DISPLAY=$(cat ${CM_CLUSTERS_API} | grep displayName | awk -F':' '{print $2}' | sed -e 's| "||' -e 's|",||')

  COUNT=1
  local IFS=$'\n'
  for CLUSTER in ${CLUSTERS}
  do
    CLUSTER_ARRAY[${COUNT}]=${CLUSTER}
    ((COUNT++))
  done
  COUNT=1
  for CLUSTER_DISPLAY in ${CLUSTERS_DISPLAY}
  do
    CLUSTER_DISPLAY_ARRAY[${COUNT}]=${CLUSTER_DISPLAY}
    echo "[${COUNT}] - ${CLUSTER_DISPLAY_ARRAY[${COUNT}]}"
    ((COUNT++))
  done
  unset IFS
  unset COUNT

  generic_entry "Please select from the options above and enter the number associated with the cluster you are wanting to make changes on - " CDH_CLUSTER_SELECTION
  CDH_CLUSTER=$(echo ${CLUSTER_ARRAY[${CDH_CLUSTER_SELECTION}]} | sed -e 's:%:%25:g' -e 's: :%20:g' -e 's:<:%3C:g' -e 's:>:%3E:g' -e 's:#:%23:g' -e 's:{:%7B:g' -e 's:}:%7D:g' -e 's:|:%7C:g' -e 's:\\:%5C:g' -e 's:\^:%5E:g' -e 's:~:%7E:g' -e 's:\[:%5B:g' -e 's:\]:%5D:g' -e 's:`:%60:g' -e 's:;:%3B:g' -e 's:/:%2F:g' -e 's:?:%3F:g' -e 's^:^%3A^g' -e 's:@:%40:g' -e 's:=:%3D:g' -e 's:&:%26:g' -e 's:\$:%24:g' -e 's:\!:%21:g' -e 's:\*:%2A:g')

  rm -f ${CM_CLUSTERS_API}
}
