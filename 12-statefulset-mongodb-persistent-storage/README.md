# Consider installing stern to check the logs for multiple pods in StatefulSet
# This Stateful has configued a volumeClaimTemplates tied to a StorageClass(nfs or cloud) for persistent storage.
# Mounted in /data/db inside of each container to store the MongoDB Data.

```
$ kubectl stern mongo  
or  
$ stern mongo # Depends on installation with brew, or on kubectl

```

# Access a Pod to manage the DB

```
$ kubectl exect -it mongo-0 -- /bin/bash
```

# Inside of the DB check the status and databases|tables
```
$ mongo
	$ rs.status()
	$ show databases
	$ use database
	$ show tables
	$ db.users.find()
```
