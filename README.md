# odoo16-ansible

## Build Virtual Box

    Build automatically a new virtual machine with next virtual box script

```sh
./mk_vmbox.sh testVM
```

## Follow Debian installation instructions

    - My recommendations is to create a different extra user "administrator"
    - Don't install the Debian GUI

## SSH configuration

    Get the ip address of the VM
```sh
ip a
```
    Copy your ssh key to that server (needed for Ansible)

```sh
ssh-copy-id administrator@192.168.1.67
```
    ssh to test the access to the VM

```sh
ssh administrator@192.168.1.67
```

## Set the IP in the hosts.yml file

```yml
all:
  children:
    prod:
      hosts:
        192.168.1.67:22
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