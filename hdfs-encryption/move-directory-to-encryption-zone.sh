#!/bin/bash
declare -A TRUTH_ARRAY=( ["y"]=true ["yes"]=true ["t"]=true ["true"]=true ["n"]=false ["no"]=false ["f"]=false ["false"]=false )

ez_parameter_count_check() {
  if [[ "${1}" -ne "${2}" ]]
  then
    printf "Expecting only ${2} parameter(s) for moving directories to an encryption zone, but "${1}" parameter(s) passed.\nExpecting ${2} parameter(s) in the pattern:\n1) [HDFS Path - Ex: /user/hive]\n2) [Directory Permissions - Ex: 744]\n3) [Directory Owner - Ex: hdfs:supergroup]\n4) [Encryption Key Name - Ex: userhive]\n"
    exit 1
  fi
}

parameter_count_check() {
  if [[ "${1}" -ne "${2}" ]]
  then
    printf "Expecting only ${2} parameter(s) for moving directories to an encryption zone, but "${1}" parameter(s) passed."
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

encrypt_in_place() {
  ez_parameter_count_check "$#" 4

  HDFS_PATH=${1}
  CHMOD_PERMISSIONS=${2}
  CHOWN_PERMISSIONS=${3}
  EZ_KEY_NAME=${4}

  HDFS_TEMP_PATH="/temp"

  echo "
hadoop mv "${HDFS_PATH}" "${HDFS_TEMP_PATH}${HDFS_PATH}"  # NOTE: This requires /temp to be created in HDFS.
hdfs dfs -mkdir "${HDFS_PATH}"
hdfs dfs -chmod "${CHMOD_PERMISSIONS}" "${HDFS_PATH}"
hdfs dfs -chown "${CHOWN_PERMISSIONS}" "${HDFS_PATH}"
hdfs crypto -createZone -keyName "${EZ_KEY_NAME}" -path "${HDFS_PATH}"
hadoop distcp -prbugp -skipcrccheck -update "${HDFS_TEMP_PATH}${HDFS_PATH}" "${HDFS_PATH}"
hdfs dfs -rm -r "${HDFS_TEMP_PATH}${HDFS_PATH}"
"
}

encrypt_to_new_ez() {
  ez_parameter_count_check "$#" 5

  HDFS_SOURCE_PATH=${1}
  HDFS_TARGET_PATH=${2}
  CHMOD_PERMISSIONS=${3}
  CHOWN_PERMISSIONS=${4}
  EZ_KEY_NAME=${5}

  echo "
hdfs dfs -mkdir "${HDFS_TARGET_PATH}"
hdfs dfs -chmod "${CHMOD_PERMISSIONS}" "${HDFS_TARGET_PATH}"
hdfs dfs -chown "${CHOWN_PERMISSIONS}" "${HDFS_TARGET_PATH}"
hdfs crypto -createZone -keyName "${EZ_KEY_NAME}" -path "${HDFS_TARGET_PATH}"
hadoop distcp -prbugp -skipcrccheck -update "${HDFS_SOURCE_PATH}" "${HDFS_TARGET_PATH}"
hdfs dfs -rm -r "${HDFS_SOURCE_PATH}"
"
}

encrypt_to_ez() {
  ez_parameter_count_check "$#" 2

  HDFS_SOURCE_PATH=${1}
  HDFS_TARGET_PATH=${2}

  echo "
hadoop distcp -prbugp -skipcrccheck -update "${HDFS_SOURCE_PATH}" "${HDFS_TARGET_PATH}"
hdfs dfs -rm -r "${HDFS_SOURCE_PATH}"
"
}

main() {
  parameter_count_check "$#" 0

  generic_entry "Please enter the source directory that will be encrypted and press [Enter]: " HDFS_SOURCE_PATH
  yes_no_entry "Is the directory ${HDFS_SOURCE_PATH} currently in an encryption zone (y/n)? " CURRENTLY_ENCRYPTED_SOURCE

  if ${CURRENTLY_ENCRYPTED_SOURCE}
  then

    generic_entry "Please enter the target directory to move ${HDFS_SOURCE_PATH} into and press [Enter]: " HDFS_TARGET_PATH
    yes_no_entry "Is the directory ${HDFS_TARGET_PATH} currently in an encryption zone (y/n)? " CURRENTLY_ENCRYPTED_TARGET

    if ${CURRENTLY_ENCRYPTED_TARGET}
    then

      encrypt_to_ez "${HDFS_SOURCE_PATH}" "${HDFS_TARGET_PATH}"

    else

      generic_entry "Please enter the name of the Encryption Key that you will be encrypting ${HDFS_SOURCE_PATH} with and press [Enter]: " EZ_KEY_NAME
      generic_entry "Please enter the desired permissions (Ex: 744) of ${HDFS_SOURCE_PATH} and press [Enter]: " CHMOD_PERMISSIONS
      generic_entry "Please enter the desired owner and group (Ex: hdfs:supergroup) of ${HDFS_SOURCE_PATH} and press [Enter]: " CHOWN_PERMISSIONS
      encrypt_to_new_ez "${HDFS_SOURCE_PATH}" "${HDFS_TARGET_PATH}" "${CHMOD_PERMISSIONS}" "${CHOWN_PERMISSIONS}" "${EZ_KEY_NAME}"

    fi

  else

    yes_no_entry "Does the directory ${HDFS_SOURCE_PATH} need to be encrypted in place (y/n)? Ex: /user/hive stays in place but data is encrypted - " ENCRYPT_IN_PLACE

    if ${ENCRYPT_IN_PLACE}
    then

      generic_entry "Please enter the name of the Encryption Key that you will be encrypting ${HDFS_SOURCE_PATH} with and press [Enter]: " EZ_KEY_NAME
      generic_entry "Please enter the desired permissions (Ex: 744) of ${HDFS_SOURCE_PATH} and press [Enter]: " CHMOD_PERMISSIONS
      generic_entry "Please enter the desired owner and group (Ex: hdfs:supergroup) of ${HDFS_SOURCE_PATH} and press [Enter]: " CHOWN_PERMISSIONS
      encrypt_in_place "${HDFS_SOURCE_PATH}" "${CHMOD_PERMISSIONS}" "${CHOWN_PERMISSIONS}" "${EZ_KEY_NAME}"

    else

      generic_entry "Please enter the target directory to move ${HDFS_SOURCE_PATH} into and press [Enter]: " HDFS_TARGET_PATH
      yes_no_entry "Is the directory ${HDFS_TARGET_PATH} currently in an encryption zone (y/n)? " CURRENTLY_ENCRYPTED_TARGET

      if ${CURRENTLY_ENCRYPTED_TARGET}
      then

        encrypt_to_ez "${HDFS_SOURCE_PATH}" "${HDFS_TARGET_PATH}"

      else

        generic_entry "Please enter the name of the Encryption Key that you will be encrypting ${HDFS_SOURCE_PATH} with and press [Enter]: " EZ_KEY_NAME
        generic_entry "Please enter the desired permissions (Ex: 744) of ${HDFS_SOURCE_PATH} and press [Enter]: " CHMOD_PERMISSIONS
        generic_entry "Please enter the desired owner and group (Ex: hdfs:supergroup) of ${HDFS_SOURCE_PATH} and press [Enter]: " CHOWN_PERMISSIONS
        encrypt_to_new_ez "${HDFS_SOURCE_PATH}" "${HDFS_TARGET_PATH}" "${CHMOD_PERMISSIONS}" "${CHOWN_PERMISSIONS}" "${EZ_KEY_NAME}"

      fi

    fi

  fi
}

main "${@}"
