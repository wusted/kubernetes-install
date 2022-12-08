#!/usr/bin/env bash

## For better usability, remeber to first create the ssh keys
## Recommendation, use the same user for every Server, Client, e.g k8s,linux,web,db. etc.

## If Hostname is going to be used.
## Then, make sure that /etc/hosts for each Server, Client has the IP and hostname set.
## Otherwise use the IP in the script when referring to Server and Clients

## ssh session section is meant to be used with Hostnames: k8s-master1 k8s-worker1 and k8s-worker2 with user k8s

## Work In Progress to create the script for /etc/hosts Hostname allocation, to be used before this one.

echo "Need SSH Creation? 0 for No, 1 for Yes"
read CREATE

if [ $CREATE -eq 1 ]
then
	echo "Enter the name or IP of 1 Target Server to Generate SSH Keys: "
	read KEY_HOST
	echo "Enter the username for the above Server for SSH: (Please use k8s) "
	read USER_HOST

	## Creates SSH Keys
	ssh $USER_HOST@$KEY_HOST ssh-keygen

	## Copy Private Keys
	echo "Enter a list separated by spaces for the SSH Clients Hostname or IPs that will execute this script to access SSH Target Hosts: "
	read CLIENTS

	for c in $CLIENTS; do ssh $USER_HOST@$KEY_HOST -- ssh-copy-id -i /home/$USER_HOST/.ssh/id_rsa $USER_HOST@$c ; done

	## Copy Public Keys
	echo "Enter a list separated by spaces for the SSH Target Server Hostname or IPs that will be accesed from SSH Clients: "
	read HOSTS

	for h in $HOSTS; do ssh $USER_HOST@$h -- mkdir -m 700 /home/$USER_HOST/.ssh/ ; done
	for h in $HOSTS; do ssh $USER_HOST@$KEY_HOST -- scp /home/$USER_HOST/.ssh/id_rsa.pub $USER_HOST@$h://home/$USER_HOST/.ssh/authorized_keys ; done
	

elif [ $CREATE -eq 0 ]
then	echo "Enter (1)k8s-master1 OR (2)k8s-worker1 OR (3)k8s-worker2"
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
	fi
fi	
