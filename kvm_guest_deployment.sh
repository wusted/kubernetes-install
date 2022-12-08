#!/usr/bin/env bash

echo ks.cfg file is needed to use this script!!

## Define variables
# Memory in MiB
echo -n "VM Memory Size in MiB: (Default 2048) "
read MEM
MEM_SIZE=$MEM

### MEM_SIZE=2048
### Pending, work in conditional for default


# CPU Cores Count
echo -n "vCPU Cores Count: (Default 2) "
read CPU
VCPUS=$CPU

### VCPUS=2
### Pending, work in conditional for default

# OSVariant - osinfo-query os
echo -n "Set OS Variant, List of option: # osinfo-query os, (default rhel9.1) "
read OS_VARIANT

### OS_VARIANT="rhel9.0"
### Pending, work in conditional for default


# ISO File Location
echo -en "Set the Location for the ISO File for Installation: "
read ISO
ISO_FILE="$ISO"

# Disk File Creation Path
echo -en "Set the Location for the New Disk File to be created: "
read DPATH
DISK_PATH="$DPATH"

# VM Name
echo -en "Set VM Name: "
read VM_NAME

# Virtual Disk Size
echo -en "Set Virtual Disk Size: "
read DISK_SIZE


## Deployment Command
sudo virt-install \
     --name $VM_NAME \
     --memory $MEM_SIZE \
     --vcpus $VCPUS \
     --location=$ISO_FILE \
     --os-variant=$OS_VARIANT \
     --disk path=$DISK_PATH,size=$DISK_SIZE \
     --network bridge=virbr0 \
     --nographics \
     --initrd-inject ks.cfg \
     --console pty,target_type=serial \
     --initrd-inject ks.cfg --extra-args "inst.ks=file:/ks.cfg console=tty0 console=ttyS0,115200n8"
     # Local ks.cfg file
     # Remote ks.cfg
     #--extra-args="ks=http|nfs://IP|localhost/ks.cfg console=tty0 console=ttyS0,115200n8"


