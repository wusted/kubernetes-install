#!/bin/bash
## Very simple bash script, next step is to store the variables for nodes in a data structure.
## And optimize the code to be less iterative


echo "Enter the K8s Cluster (1)k8s-test, (2)k8s-cp, (3)k8s-master: "
read CLUSTER
echo "Enter 'start' or 'stop': "
read ACTION

## Starts or Stops Cluster 1; k8s-test1, k8s-test2, k8s-test3 
if [ $CLUSTER -eq 1 ]
then

	if [ $ACTION == "start" ]
	then
	for a in k8s-test{1..3}; do virsh $ACTION $a; done
	
	elif [ $ACTION == "stop" ] 
	then
	for b in k8s-test{1..3}; do virsh $ACTION $b; done
	
fi

## Starts or Stops Cluster 2; k8s-cp1, k8s-w1, k8s,w2
elif [ $CLUSTER -eq 2 ]
then
	if [ $ACTION == "start" ]
       	then
	for c in k8s-cp1 k8s-w1 k8s-w2; do virsh $ACTION $c; done
	
	elif [ $ACTION == "stop" ]
      	then
	for d in k8s-cp1 k8s-w1 k8s-w2; do virsh $ACTION $d; done
fi

## Starts or Stops Cluster 3; k8s-master1 k8s-worker1 k8s-worker2
elif [ $CLUSTER -eq 2 ]
then
if [ $ACTION == "start" ]
then
echo "start"
for e in k8s-master1 k8s-worker1 k8s-worker2; do virsh start $e; done
	
elif [ $ACTION == "stop" ]
then
for f in k8s-master1 k8s-worker1 k8s-worker2; do virsh stop $f; done
fi
fi

