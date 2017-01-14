# OpenLDAP Client Security Configuration

When integrating services with external authentication via LDAP it is highly recommended to enable TLS/SSL communication between the service (LDAP client) and LDAP server (via LDAPS).  This assumes that LDAPS is configured on the server you are integrating with and that the certificates needed to communicate with the LDAPS server are known or can be retrieved.

The setup script walks you through building of the certificate directory on the client machine to ensure the files are referenced correctly.  It will ask if you have the certificates already on the node and if you do not, can retrieve the certificate from the server on the LDAPS port 636.

```vim
./setup-ldaps.sh
```

**Note**: This was tested against 2012 AD with LDAPS enabled and an AD CA.

## Search LDAP

Once the configuration is complete it is now possible to search users in the LDAP directory.  You can optionally pass parameters or provide input from the command prompt.

```vim
./search-user.sh [LDAP Host] [LDAP Bind] [Search Account Name]
```

## Delete SPN's

If you have integrated Hadoop with AD it occasionally requires deleting service principals from AD.  When users are created they are created via SPN's which is what this script provides as a search option.  This script will find the username and generate a delete statement that can be run to delete the SPN.  You can optionally pass parameters or provide input from the command prompt.

**SPN Example**: hdfs/ip-172-0-0-1.ec2.internal@EXAMPLE.COM


```vim
./hadoop-delete-spns.sh [LDAP Host] [LDAP Bind] [Service List] [Host List]
```
