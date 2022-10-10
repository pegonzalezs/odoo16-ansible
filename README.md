# My first Odoo 16 CE deployment in a few steps
## SSH configuration

    Get the ip address of the VM / Server
```sh
ip a
```
    Copy your ssh key to that server (needed for Ansible)

```sh
ssh-copy-id administrator@your_vn_ip
```
    ssh to test the access to the VM

```sh
ssh administrator@your_vm_ip
```

## Set the IP in the hosts.yml file

```yml
all:
  children:
    prod:
      hosts:
        your_vm_ip:22
```
## Configure sudoers

```sh
nano /etc/sudoers
```

    Add next line

```sh
administrator ALL=(ALL) NOPASSWD:ALL
```

## Run Ansible

```sh
ansible-playbook odoo16-deploy.yml -i hosts.yml
```

## Configure CertBot

    In case you need to create a certificate follow instructions described
    in roles/nginx/journal.txt

## Build Virtual Box VM (Dev Deployment)

    Build automatically a new virtual machine with next virtual box script
    In case you want to host Odoo in a local virtual machine
    Get the interface name of the adapter your VM will use with next command

```sh
VBoxManage list bridgedifs | grep -m1 Name | awk '{print $2}'
```

    Replace the name in line INTERFACE inside mk_vmbox.sh
    Run the vm builder script

```sh
./mk_vmbox.sh Odoo16-VM
```
## Follow Debian installation instructions

    - My recommendations is to create a different extra user "administrator"
    - Don't install the Debian GUI
    - Install the SSH Server Package
