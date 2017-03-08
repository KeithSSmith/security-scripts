#!/bin/bash

enable-tls-spark() {
  curl -X PUT -u ${CLOUDERA_MANAGER_USER}:${CLOUDERA_MANAGER_USER_PASSWORD} -i \
  --cacert ${CLOUDERA_MANAGER_CA_PEM} \
  -H "content-type:application/json" \
  -d '{ "items" :
    [
      {
        "name" : "spark-conf/spark-defaults.conf_client_config_safety_valve",
        "value" : "spark.authenticate=true \nspark.shuffle.encryption.enabled=true\nspark.shuffle.encryption.keySizeBits=256\nspark.shuffle.encryption.keygen.algorithm=HmacSHA256\nspark.shuffle.crypto.cipher.transformation=AES/CTR/NoPadding\nspark.network.sasl.serverAlwaysEncrypt=true\nspark.authenticate.enableSaslEncryption=true\nspark.acls.enable=true"
      }
    ]
  }' https://${CLOUDERA_MANAGER_HOSTNAME}:7183/api/${CM_API_VERSION}/clusters/${CDH_CLUSTER}/services/spark_on_yarn/roleConfigGroups/spark_on_yarn-GATEWAY-BASE/config
}
