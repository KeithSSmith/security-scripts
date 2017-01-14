#!/bin/bash
set -e
PEM_FILE=''
declare -A TRUTH_ARRAY=( ["y"]=true ["yes"]=true ["t"]=true ["true"]=true ["n"]=false ["no"]=false ["f"]=false ["false"]=false )

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

zero_pad_number() {
  parameter_count_check "$#" 3
  eval "${3}=$( printf %0${2}d ${1} )"
}

check_number() {
  parameter_count_check "$#" 2

  START_LENGTH=${#1}
  END_LENGTH=${#2}
  START_BASE=$((10#$1))
  END_BASE=$((10#$2))
  START_BASE_LENGTH=${#START_BASE}
  END_BASE_LENGTH=${#END_BASE}
  START_ZEROS=$((${START_LENGTH} - ${START_BASE_LENGTH}))
  END_ZEROS=$((${END_LENGTH} - ${END_BASE_LENGTH}))
  START=${START_BASE}
  END=${END_BASE}

  if [[ "${START}" -gt "${END}" ]]
  then
    echo "Please choose an ending value larger than the starting value (Start: ${START} > End: ${END})"
  fi

  if [[ "${START_ZEROS}" -gt "0" ]]
  then
    zero_pad_number ${START} ${START_LENGTH} START
  fi

  if [[ "${END_ZEROS}" -gt "0" ]]
  then
    zero_pad_number ${END} ${END_LENGTH} END
  fi

  if [[ "${#START}" -gt "${#END}" ]]
  then
    echo "Start value (${START}) is zero padded to ${#START} places, while the Ending value (${END}) does not match the padding length, changing to proper padding."
    zero_pad_number ${END_BASE} ${#START} END
  fi

  if [[ "${END_ZEROS}" -gt "0" ]] && [[ "${#END}" -gt "${#START}" ]]
  then
    echo "End value (${END}) is zero padded to ${#END} places, while the Starting value (${START}) does not match the padding length, changing to proper padding."
    zero_pad_number ${START_BASE} ${#END} START
  fi
}

generate_fqdn() {
  parameter_count_check "$#" 5

  for NUM in $(eval echo "{${2}..${3}}")
  do
    HOSTS+=("${1}${NUM}.${4}")
  done

  for HOST in $( echo "${HOSTS[@]}" )
  do
    echo ${HOST}
  done
}

write_hosts() {
  parameter_count_check "$#" 1

  if ${TRUTH_ARRAY[${1}]}
  then
    for HOST in $( echo "${HOSTS[@]}" )
    do
      echo ${HOST} >> ${HOST_LIST}
    done

    unset HOSTS
    clear
    echo "File Written! Current hosts list contains the following:"
    cat ${HOST_LIST}
  else
    unset HOSTS
  fi
}

directory_entry() {
  parameter_count_check "$#" 3
  generic_read "${1}"

  if [[ -z ${ENTRY} ]]
  then
    yes_no_entry "No value entered, use default value: '${3}' (y/n)? " USE_DIRECTORY_DEFAULT

    if ${USE_DIRECTORY_DEFAULT}
    then
      eval "${2}=${3}"
    else
      directory_entry "${1}" "${2}" "${3}"
    fi

  else
    eval "${2}=\"${ENTRY}\""
  fi
}

keystore_file_extenstion() {
  parameter_count_check "$#" 2
  generic_read "${1}"

  if [[ -z ${ENTRY} ]]
  then
    yes_no_entry "No value entered, using default value: 'keystore' (y/n)? " USE_KEYSTORE_DEFAULT

    if ${USE_KEYSTORE_DEFAULT}
    then
      eval "${2}=keystore"
    else
      keystore_file_extenstion "${PROMPT}" "${2}"
    fi

  else
    eval "${2}=\"${ENTRY}\""
  fi
}

check_file_exists() {
  parameter_count_check "$#" 1

  if test -n "$(find ${CERTIFICATE_DIRECTORY}/jks -maxdepth 1 -name "*.${KEYSTORE_FILE_EXTENSION}" -print -quit)"
  then
    yes_no_entry "File ${1} exists, remove it and continue to next step (y/n)? " REMOVE_FILE

    if ${REMOVE_FILE}
    then
      REMOVE_EXISTING_KEYSTORE="printf 'Removing keystore...\n'; rm -f ${1};"
    else
      keystore_file_extenstion "Enter keystore file extension (Default: keystore) and press [Enter]: " KEYSTORE_FILE_EXTENSION
    fi

  else
    printf "${1} doesn't exist, continuing to next step.\n"
  fi
}

create_certificate_directory() {
  parameter_count_check "$#" 1

  printf "Creating Directory: ${1}/jks ...\n"
  mkdir -p "${1}/jks"

  printf "Creating Directory: ${1}/x509 ...\n"
  mkdir -p "${1}/x509"

  printf "Creating Directory: ${1}/CAcerts ...\n"
  mkdir -p "${1}/CAcerts"
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

distinguished_name_entry() {
  parameter_count_check "$#" 1

  generic_entry "Organization Unit (OU): " ORGANIZATION_UNIT
  generic_entry "Organization (O): " ORGANIZATION
  generic_entry "Location (L): " LOCATION
  generic_entry "State (ST): " STATE
  generic_entry "Country (C): " COUNTRY

  DISTINGUISHED_NAME="OU=${ORGANIZATION_UNIT},O=${ORGANIZATION},L=${LOCATION},ST=${STATE},C=${COUNTRY}"
  yes_no_entry "Is this the desired Distinghuished Name '${DISTINGUISHED_NAME}' (y/n): " DISTINGUISHED_CHECK

  if ! ${DISTINGUISHED_CHECK}
  then
    distinguished_name_entry DISTINGUISHED_NAME
  fi
}

collect_csrs() {
  parameter_count_check "$#" 1

  printf "Creating Local Directory: ${1} ...\n"
  mkdir -p "${1}"

  printf "Collecting CSR's ...\n"
  for HOST in $(cat /tmp/hosts)
  do
    scp ${PEM_FILE} ${HOST}:${CERTIFICATE_DIRECTORY}/x509/${HOST}.csr "${1}"
  done

  printf "Submit the CSR's for Signing with a Certificate Authority and place all Signed Certificates on this server and run 02_build-keystores.sh ...\n"
}

san_builder() {
  parameter_count_check "$#" 1

  yes_no_entry "${1}" SAN_CHECK

  if ${SAN_CHECK}
  then
    MORE_SAN=true

    while ${MORE_SAN}
    do
      generic_entry "Enter SAN (Ex: cloudera-manager.example.com): " SAN_NAME
      yes_no_entry "Enter ${SAN_NAME} into keystore (y/n)? " SAN_ENTRY
      if ${SAN_ENTRY}
      then
        SAN_STRING=${SAN_STRING}",dns:${SAN_NAME}"
      fi
      yes_no_entry "Would you like to include any other SAN's to the certificate (y/n)? " MORE_SAN
    done

  fi

}
