#!/bin/bash

echo "Namespace?: "
read namespace

echo "Pod Label?: "
read label

echo "Pod Label Value?: "
read value

watch "kubectl get pods -n $namespace --selector=$label=$value && kubectl get hpa -n $namespace"

