#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Install virtualization packages
echo "Installing virtualization packages..."
dnf install -y @virtualization

# Enable and start libvirtd service
echo "Enabling and starting libvirtd service..."
systemctl enable --now libvirtd.service

# Verify installation
echo "Verifying installation..."
virsh list --all && virt-host-validate

if [ $? -eq 0 ]; then
   echo "KVM and libvirt are now installed and configured on this system."
else
   echo "Error: libvirt configuration is incorrect. Please check system logs for details."
   exit 1
fi
