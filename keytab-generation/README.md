# Keytab Generation

**NOTE**: It is not recommended to use this approach any longer as connecting directly with AD is far more reliable/scalable.

This collection of scripts can be referenced for User Creation via LDAP Modify, keytab building via ktutil, and scripts to retrieve keytabs for Cloudera Manager.  These scripts can be used to help automate the SPN creation inside of AD when direct integration is not allowed.

## Build Users with both Scripts

```vim
source ad_to_cm_keytab_creation.sh [LDAP IP/Hostname] [Account Name with Create Access]
```

## AD Account Creation via LDAP Modify

```vim
source ad_account_creation.sh [LDAP IP/Hostname] [Account Name with Create Access]
```


## AD Keytab Creation via ktutil

```vim
source ad_keytab_creation.sh
```

All of the above files pull from the ad_accounts.txt file and need to match the services and IP's that are in the customers environment.
