#!/bin/bash

echo You would a need ks.cfg file to use this script!!

## Define variables
# Memory in MiB
echo -n "VM Memory Size in MiB: (Default 2048) "
read MEMORY
MEM_SIZE=$MEMORY
# Pending, work in conditional for default

# CPU Cores Count
echo -n "vCPU Cores Count: (Default 2) "
read CPU
VCPUS=$CPU
# Pending, work in conditional for default

# OSVariant - osinfo-query os
echo -n "Set OS Variant, List of option: # osinfo-query os, default rhel9.1 "
read OS
OS_VARIANT=$OS
# Pending, work in conditional for default

# ISO File Location
echo -en "Set the Location for the ISO File for Installation: "
read ISO_FILE

# Disk File Creation Path
echo -en "Set the Location for the New Disk File to be created: "
read DISK_PATH

# VM Name
echo -en "Set VM Name: "
read VM_NAME

# Virtual Disk Size
echo -en "Set Virtual Disk Size: "
read DISK_SIZE


## Deployment Command
sudo virt-install \
     --name ${VM_NAME} \
     --memory ${MEM_SIZE} \
     --vcpus {$VCPUS} \
     --os-variant={$OS_VARIANT} \
     --location={$ISO_FILE} \
     --disk path={$DISK_PATH} \
     --disk size={$DISK_SIZE} \
     --network bridge=virbr0 \
     --nographics \
     --initrd-inject ks.cfg \
     # Local ks.cfg file
     --extra-args "inst.ks=file:/ks.cfg console=ttyS0" 
     # Remote ks.cfg
     #--extra-args "ks=http/nfs://IP/ks.cfg console=ttyS0"


#--disk path=/home/kvm/vdisks/k8s-master1,size=85 
# --extra-args "console=tty0 console=ttyS0,115200n8"
