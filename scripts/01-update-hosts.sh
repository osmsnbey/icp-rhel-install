#!/bin/bash
# Constructs hosts file

# Get the variables
source 00-variables.sh

# Back up old hosts file
sudo cp /etc/hosts /etc/hosts.bak

echo "127.0.0.1 localhost" | sudo tee /etc/hosts
echo "" | sudo tee -a /etc/hosts

echo "fe00::0 ip6-localnet" | sudo tee -a /etc/hosts
echo "ff00::0 ip6-mcastprefix" | sudo tee -a /etc/hosts
echo "ff02::1 ip6-allnodes" | sudo tee -a /etc/hosts
echo "ff02::2 ip6-allrouters" | sudo tee -a /etc/hosts
echo "ff02::3 ip6-allhosts" | sudo tee -a /etc/hosts
echo "" | sudo tee -a /etc/hosts

# Loop through the array for all master
echo "# Master Nodes" | sudo tee -a /etc/hosts
for ((i=0; i < $NUM_MASTER; i++)); do
  echo "${MASTER_IPS[i]} ${MASTER_HOSTNAMES[i]} ${MASTER_HOSTNAMES_SHORT[i]}" | sudo tee -a /etc/hosts
done
echo "" | sudo tee -a /etc/hosts

# Loop through the array for all proxys
echo "# Proxy Nodes" | sudo tee -a /etc/hosts
for ((i=0; i < $NUM_PROXY; i++)); do
  echo "${PROXY_IPS[i]} ${PROXY_HOSTNAMES[i]} ${PROXY_HOSTNAMES_SHORT[i]}" | sudo tee -a /etc/hosts
done
echo "" | sudo tee -a /etc/hosts

# Loop through the array for all Management nodes
echo "# Management Nodes" | sudo tee -a /etc/hosts
for ((i=0; i < $NUM_MANAGE; i++)); do
  echo "${MANAGE_IPS[i]} ${MANAGE_HOSTNAMES[i]} ${MANAGE_HOSTNAMES_SHORT[i]}" | sudo tee -a /etc/hosts
done
echo "" | sudo tee -a /etc/hosts


# Loop through the array for all worker
echo "# Worker Nodes" | sudo tee -a /etc/hosts
for ((i=0; i < $NUM_WORKERS; i++)); do
  echo "${WORKER_IPS[i]} ${WORKER_HOSTNAMES[i]} ${WORKER_HOSTNAMES_SHORT[i]}" | sudo tee -a /etc/hosts
done
echo "" | sudo tee -a /etc/hosts

sudo cp /etc/hosts ~/worker-hosts
sudo chown $USER ~/worker-hosts

echo "$MASTER_IP mycluster.icp" | sudo tee -a /etc/hosts

# for all Master starting with the second one (first one is actual server)
for ((i=1; i < $NUM_MASTER; i++)); do
  # Remove old instance of host
  ssh-keygen -R ${MASTER_IPS[i]}
  ssh-keygen -R ${MASTER_HOSTNAMES[i]}

  # Do not ask to verify fingerprint of server on ssh
  ssh-keyscan -H ${MASTER_IPS[i]} >> ~/.ssh/known_hosts
  ssh-keyscan -H ${MASTER_HOSTNAMES[i]} >> ~/.ssh/known_hosts

  # Copy over file
  sudo scp -i ${SSH_KEY} ~/worker-hosts  ${SSH_USER}@${MASTER_HOSTNAMES[i]}:~/worker-hosts

  # Replace worker hosts with file
  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo cp /etc/hosts /etc/hosts.bak; sudo mv ~/worker-hosts /etc/hosts'
done

# for all proxy
for ((i=0; i < $NUM_PROXY; i++)); do
  # Remove old instance of host
  ssh-keygen -R ${PROXY_IPS[i]}
  ssh-keygen -R ${PROXY_HOSTNAMES[i]}

  # Do not ask to verify fingerprint of server on ssh
  ssh-keyscan -H ${PROXY_IPS[i]} >> ~/.ssh/known_hosts
  ssh-keyscan -H ${PROXY_HOSTNAMES[i]} >> ~/.ssh/known_hosts

  # Copy over file
  sudo scp -i ${SSH_KEY} ~/worker-hosts  ${SSH_USER}@${PROXY_HOSTNAMES[i]}:~/worker-hosts

  # Replace worker hosts with file
  ssh -i ${SSH_KEY} ${SSH_USER}@${PROXY_HOSTNAMES[i]} 'sudo cp /etc/hosts /etc/hosts.bak; sudo mv ~/worker-hosts /etc/hosts'
done

# for all Management nodes
for ((i=0; i < $NUM_MANAGE; i++)); do
  # Remove old instance of host
  ssh-keygen -R ${MANAGE_IPS[i]}
  ssh-keygen -R ${MANAGE_HOSTNAMES[i]}

  # Do not ask to verify fingerprint of server on ssh
  ssh-keyscan -H ${MANAGE_IPS[i]} >> ~/.ssh/known_hosts
  ssh-keyscan -H ${MANAGE_HOSTNAMES[i]} >> ~/.ssh/known_hosts

  # Copy over file
  sudo scp -i ${SSH_KEY} ~/worker-hosts  ${SSH_USER}@${MANAGE_HOSTNAMES[i]}:~/worker-hosts

  # Replace worker hosts with file
  ssh -i ${SSH_KEY} ${SSH_USER}@${MANAGE_HOSTNAMES[i]} 'sudo cp /etc/hosts /etc/hosts.bak; sudo mv ~/worker-hosts /etc/hosts'
done

# for all workers
for ((i=0; i < $NUM_WORKERS; i++)); do
  # Remove old instance of host
  ssh-keygen -R ${WORKER_IPS[i]}
  ssh-keygen -R ${WORKER_HOSTNAMES[i]}

  # Do not ask to verify fingerprint of server on ssh
  ssh-keyscan -H ${WORKER_IPS[i]} >> ~/.ssh/known_hosts
  ssh-keyscan -H ${WORKER_HOSTNAMES[i]} >> ~/.ssh/known_hosts

  # Copy over file
  sudo scp -i ${SSH_KEY} ~/worker-hosts  ${SSH_USER}@${WORKER_HOSTNAMES[i]}:~/worker-hosts

  # Replace worker hosts with file
  ssh -i ${SSH_KEY} ${SSH_USER}@${WORKER_HOSTNAMES[i]} 'sudo cp /etc/hosts /etc/hosts.bak; sudo mv ~/worker-hosts /etc/hosts'
done
