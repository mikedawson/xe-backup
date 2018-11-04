#!/bin/bash

# Export a XEN virtual machine to XVA, even if it is running
# Inspired by NAUBackup ( https://github.com/NAUbackup/VmBackup ),
#  but created to allow backing up remote VMs using XAPI over the network.

VM_NAME=""
DEST_DIR="/snapshots/BACKUPS"
BACKUPS_TO_KEEP=3

while [ "$1" != "" ]; do
    case $1 in
	-vm | --virtualmachine )  shift
		VM_NAME=$1
		;;
        -dir | --dir ) 		  shift
		DEST_DIR=$1
       		;;
        -b | --backups-to-keep )  shift
		BACKUPS_TO_KEEP=$1
		;;
    esac
    shift
done

usage() {
    echo "Usage $0 : -vm <VM-NAME> -dir <DEST-DIR> -b <NUM_BACKUPS_TO_KEEP>"
    echo " e.g. $0 -vm VMNAME -dir /path/to/export/dir -b 3"
    echo "If you want to export a remote VM, run "
    echo "export XE_EXTRA_ARGS=server=HOSTNAME_OR_IP,username=root,password=secret"
}

echo "Backup settings:"
echo "VM_NAME : $VM_NAME"
echo "DEST_DIR : $DEST_DIR"
echo "BACKUPS_TO_KEEP : $BACKUPS_TO_KEEP"

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
RUNNING_STATE=$(xe vm-list name-label="$VM_NAME" params=power-state)

XVA_PATH="$DEST_DIR/$VM_NAME/$TIMESTAMP-backup/$VM_NAME.xva"

mkdir -p $(dirname $XVA_PATH)
if [ "$RUNNING_STATE" != "" ]; then
	# Its running - use the snapshot method
	echo "export: $VM_NAME is running, taking snapshot then exporting"
	SNAPSHOT_UUID=$(xe vm-snapshot vm="$VM_NAME" new-name-label="RESTORE_$VM_NAME")
	xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAPSHOT_UUID
	xe vm-export uuid=$SNAPSHOT_UUID filename=$XVA_PATH
	xe vm-uninstall uuid=$SNAPSHOT_UUID force=true
else
	xe vm-export vm=$VM_NAME filename=$XVA_PATH
fi

echo "Exported $VM_NAME to $XVA_PATH"

WORKINGDIR=$(pwd)
cd $DEST_DIR/$VM_NAME/
NUMBACKUPS=$(ls -1d *backup | wc -l)
TODELETE=$(ls -1d *backup | head -n $(expr $NUMBACKUPS - $BACKUPS_TO_KEEP))
echo "Deleting $TODELETE old backups ( keeping $BACKUPS_TO_KEEP)"
rm -rf $TODELETE

echo "Done"

