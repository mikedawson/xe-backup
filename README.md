# Xen Server Backup Script

This script allows for Xen Server VMs to be exported, whether they are running or shutdown. It then keeps a given number backups, and deletes old backups.

Use it as follows:
```
export XE_EXTRA_ARGS="server=HOSTNAME_OR_IP,username=root,password=secret"
chmod a+x xe-backup.sh
./xe-backup.sh -vm VM_NAME
```
Where HOSTNAME_OR_IP is the hostname / IP of the Xen Host, and password is the password to the xen server (or a xe password file)

# Install Xe Command Line Interface

This script has been tested on Ubuntu. The xe command must be installed first. To install it, you must install the xapi-xe package.
This is not currently available directly for Ubuntu, but it can be easily converted. Find the xapi-xe rpm on the Xen Center ISO image, then convert it using the alien command.
e.g.

```
sudo apt-get update
sudo apt-get install alien
sudo alien xapi-xe-1.110.1-1.x86_64.rpm
sudo dpkg -i xapi-xe_1.110.1-2_amd64.deb
```
