#!/bin/bash
VBOX_VERSION=$(vboxmanage --version)
if [ -z "$VBOX_VERSION" ]
then
	echo "Vbox is not installed. Please install it with: apt-get install virtualbox";
    exit;
fi

MACHINENAME=$1
if [ -z "$MACHINENAME" ]
then
	echo "missing name. Usage: mk_vbox NAME-of-the-VBOX"; exit;
fi

VBOX_PATH="/home/pedro/VirtualBox VMs"
# if folder does not exists
if [ ! -d "$VBOX_PATH" ]
then
    echo """Vbox folder $VBOX_PATH does not exists.
    Please introduce your VBox default folder in variable VBOX_PATH unning next command:
    VBoxManage list systemproperties | grep folder """;
    exit;
fi

# Check that you have enough RAM
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
if [[ $RAM_KB -lt 6291456 ]]; then               # 6G = 6*1024*1024k
     # less than 6GBs of RAM!
		 echo "Your machine has less than 6GB of RAM."
		 echo "You might not be able to create a VM with 4GB of RAM"
		 exit
fi

# Check that you have enough free space
# 3.6GB for Debian ISO + 50GB for VM + additional space to run local system
FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h
if [[ $FREE -lt 57671680 ]]; then               # 55G = 55*1024*1024k
     # less than 55GBs free!
		 echo "You need to have at least 55GB free disk space to continue"
		 exit
fi

# Download debian.iso
ISO_FILE=https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-11.4.0-amd64-DVD-1.iso
# use ISO_FILE_ALTERNATE if you have problems to access the debian main server
# ISO_FILE_ALTERNATE=http://debian.ethz.ch/debian-cd/11.3.0/amd64/iso-dvd/debian-11.3.0-amd64-DVD-1.iso -O debian.iso
if [ ! -f ./debian.iso ]; then
    wget $ISO_FILE -O debian.iso
fi

# check if download worked
myfilesize=$(stat --format=%s "debian.iso")
echo "size of the debian.iso file is:"
echo "$myfilesize"
if [ ! -s ./debian.iso ]; then
    echo "the  downloaded/existing file debian.iso is invalid. This probably means the debian.iso file name has changed"
    echo "and you have to adapt the ISO_FILE in this script"
    exit
fi

# Main local interface
# TODO Extract from block of interfaces the one in status "Up" otherwise it fails
#INTERFACE=$(VBoxManage list bridgedifs | grep -m1 Name | awk '{print $2}')
INTERFACE="enx806d97068fdb"

# Find interface
if [ -z "$INTERFACE" ]; then
    echo "No interface found. Please connect a network interface to the VM"
    exit
else
    echo "Interface $INTERFACE found"
fi

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype "Debian_64" --register

#Set memory and network
VBoxManage modifyvm $MACHINENAME --ioapic on
VBoxManage modifyvm $MACHINENAME --memory 4096 --vram 128
VBoxManage modifyvm $MACHINENAME --nic1 bridged --bridgeadapter1 $INTERFACE

# Create Disk and connect Debian Iso (Size 50 GB)
VBoxManage createhd --filename "$VBOX_PATH/$MACHINENAME/$MACHINENAME.vdi" --size 51200 --format VDI

# add storage controller to be used by the virtual HD
VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --bootable on
# attach virtual HD to the controller
VBoxManage storageattach  $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VBOX_PATH/$MACHINENAME/$MACHINENAME.vdi"

# create virtual dvd drive and insert downloaded iso
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --bootable on
VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1  --device 0 --type dvddrive --medium `pwd`/debian.iso
VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk

# mischelanious settings
VBoxManage modifyvm $MACHINENAME  --clipboard bidirectional --draganddrop bidirectional --cpus 2

# Start the VM
VBoxManage startvm $MACHINENAME

# Now configure the correct network interface bridged
