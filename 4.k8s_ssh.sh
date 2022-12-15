#!/usr/bin/env bash

## For better usability, remeber to first create the ssh keys
## Recommendation, use the same user for every Server, Client, e.g k8s,linux,web,db. etc.

## If Hostname is going to be used.
## Then, make sure that /etc/hosts for each Server, Client has the IP and hostname set.
## Otherwise use the IP in the script when referring to Server and Clients

## ssh session section is meant to be used with Hostnames: k8s-master1 k8s-worker1 and k8s-worker2 with user k8s

## Work In Progress to create the script for /etc/hosts Hostname allocation, to be used before this one.
##			to store the passwords in a env variable to enter when prompted
##			to store /etc/hosts in all the created nodes, after ssh passwordless


echo "Make sure to have SSH Key Pair (ssh-keygen) - Press Enter"
echo "Need to add SSH Hosts? (0)No and contine to SSH login, OR (1)Yes"
read CREATE

if [ $CREATE -eq 1 ]
then
	echo "Enter the name or IP of Server that stores SSH Key Pair: "
	read KEY_HOST
	echo "Enter the username for the above Server that stores keys in ~/.ssh: "
	read USER_HOST
	echo "Enter the username for the Target SSH Hosts to copy the keys in ~/.ssh: "
	read USER_SSH

	## Use Own Keys.
	echo "Enter the path for Directory that stores the local Public Key and Private Keys to be copied (i.e /home/user/.ssh | /root/.ssh/): "
	read KEY_PATH

	# Copy Private Keys
	#echo "Enter a list separated by spaces for the SSH Clients Hostname or IPs that will execute this script to access SSH Target Hosts: "
	#read CLIENTS

	#for c in $CLIENTS; do ssh $USER_HOST@$c -- mkdir -m 700 /home/$USER_HOST/.ssh/ ; done
	#for c in $CLIENTS; do ssh $USER_HOST@$KEY_HOST -- scp $KEY_PATH/id_rsa $USER_HOST@$c://home/$USER_HOST/.ssh/ ; done

	## Copy Public Keys
	echo "Enter a list separated by spaces for the SSH Target Server Hostname or IPs that will be accesed from SSH Clients: "
	read HOSTS

	for h in $HOSTS; do ssh $USER_SSH@$h -- mkdir -m 700 /home/$USER_SSH/.ssh/ ; done
	for h in $HOSTS; do scp $USER_HOST@$KEY_HOST://$KEY_PATH/id_rsa.pub $USER_SSH@$h://home/$USER_SSH/.ssh/authorized_keys ; done
	

	# To-do: use the variables from /etc/hosts instead of manually typing each hostname.
elif [ $CREATE -eq 0 ]
then	echo "Enter (1)k8s-master1 OR (2)k8s-worker1 OR (3)k8s-worker2 OR (4)k8s-cp1 OR (5)k8s-w1 OR (6)k8s-w2 OR (7)k8s-test1 OR (8)k8s-test2 OR (9)k8s-test3"
	read NODE
	
	if [ $NODE -eq 1 ]
	then
	ssh k8s@k8s-master1
	
	elif [ $NODE -eq 2 ]
	then
	ssh k8s@k8s-worker1
	
	elif [ $NODE -eq 3 ]
	then
	ssh k8s@k8s-worker2

	elif [ $NODE -eq 4 ]
	then
	ssh k8s@k8s-cp1

	elif [ $NODE -eq 5 ]
	then
	ssh k8s@k8s-w1

	elif [ $NODE -eq 6 ]
	then
	ssh k8s@k8s-w2

	elif [ $NODE -eq 7 ]
	then
	ssh k8s@k8s-test1

	elif [ $NODE -eq 8 ]
	then
	ssh k8s@k8s-test2

	elif [ $NODE -eq 9 ]
	then
	ssh k8s@k8s-test3



	fi
fi	
