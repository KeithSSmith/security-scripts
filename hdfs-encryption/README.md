# Encrypt Data with HDFS at Rest Encryption

The purpose of this script is to help demonstrate the process of moving data between encryption zones.  This can be used as a guide to help generate a run sheet of commands to be used to ensure data is properly encrypted in HDFS encryption zones as defined by internal policy.  It is very common for clusters to start out with zero encryption zones and transition to a requirement of data encryption at rest.  It is also common to move data between encryption zones when new requirements arise for more granular levels of encryption.

This script is self contained and only outputs commands to be run by a Hadoop admin.

```vim
source move-directory-to-encryption-zone.sh
```

Output of this script will look like the following and requires the encryption key be created before executing the list of commands demonstrated:

```vim
hadoop mv /user/hive/warehouse /temp/user/hive/warehouse  # NOTE: This requires /temp to be created in HDFS.
hdfs dfs -mkdir /user/hive/warehouse
hdfs dfs -chmod 744 /user/hive/warehouse
hdfs dfs -chown hive:hive /user/hive/warehouse
hdfs crypto -createZone -keyName user_hive_warehouse -path /user/hive/warehouse
hadoop distcp -prbugp -skipcrccheck -update /temp/user/hive/warehouse /user/hive/warehouse
hdfs dfs -rm -r /temp/user/hive/warehouse
```
