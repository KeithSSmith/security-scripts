#!/bin/bash
set -e
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
