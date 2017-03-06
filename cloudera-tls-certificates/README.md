# Cloudera Manager TLS Certificate Builder

The purpose of this project is to help document and automate the process of building Java keystores and Non-Java Base 64 (PEM) files.  This should be used to help guide you through the certificate creation process as CLI tries to walk you through the steps you need to perform.  These scripts should be run in numbered order and a couple other requirements are as follows:

* Java installed and keytool is in the environment PATH variable on every node.
* Executing this as the root user.
* Root user can SSH between all nodes in the cluster (preferably with password-less SSH Key files).
* All certificates are presented in Base 64 (PEM) format, if they are in a different format it would be best to transform it into Base 64 format before proceeding.

**NOTE**: This is experimental and is designed to cover the basics of certificate creation, please consult your internal security professional before generating or using certificates to ensure they follow company policy and standards.
