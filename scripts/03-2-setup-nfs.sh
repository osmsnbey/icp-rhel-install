#!/bin/bash

# Get the variables
source 00-variables.sh

for ((i=0; i < $NUM_MASTER; i++)); do
    echo "setting up nfs storage on " ${MASTER_HOSTNAMES[i]}
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage ] && sudo mkdir -p /storage'

    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share01  ] && sudo mkdir -p /storage/share01 && sudo chmod 777 /storage/share01'
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share02  ] && sudo mkdir -p /storage/share02 && sudo chmod 777 /storage/share02'
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share03  ] && sudo mkdir -p /storage/share03 && sudo chmod 777 /storage/share03'
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share04  ] && sudo mkdir -p /storage/share04 && sudo chmod 777 /storage/share04'
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share05  ] && sudo mkdir -p /storage/share05 && sudo chmod 777 /storage/share05'
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share06  ] && sudo mkdir -p /storage/share06 && sudo chmod 777 /storage/share06'
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share07  ] && sudo mkdir -p /storage/share07 && sudo chmod 777 /storage/share07'
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share08  ] && sudo mkdir -p /storage/share08 && sudo chmod 777 /storage/share08'
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share09  ] && sudo mkdir -p /storage/share09 && sudo chmod 777 /storage/share09'
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} '[ ! -d /storage/share10  ] && sudo mkdir -p /storage/share10 && sudo chmod 777 /storage/share10'

    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'echo "/storage           *(rw,sync,no_subtree_check,async,insecure,no_root_squash)" | sudo tee --append /etc/exports > /dev/null'
#    echo "/storage           *(rw,sync,no_subtree_check,async,insecure,no_root_squash)" | sudo tee --append /etc/exports > /dev/null
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo systemctl restart nfs'
done
#SCRIPT