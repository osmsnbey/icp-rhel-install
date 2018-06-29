#!/bin/bash
# User steps for password-less communications

source ./00-variables.sh

# Generate RSA key
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -N ""

# Move RSA key to workers
echo "move RSA key to workers"
for ((i=0; i < $NUM_WORKERS; i++)); do
  # Prevent SSH identity prompts
  # If host IP exists in known hosts remove it
  ssh-keygen -R ${WORKER_IPS[i]}
  # Add host IP to known hosts
  ssh-keyscan -H ${WORKER_IPS[i]} | tee -a ~/.ssh/known_hosts
  
  # Copy over key (Will prompt for password)
  scp ~/.ssh/id_rsa.pub ${SSH_USER}@${WORKER_IPS[i]}:~/id_rsa.pub
  ssh ${SSH_USER}@${WORKER_IPS[i]} 'mkdir -p ~/.ssh; cat ~/id_rsa.pub | tee -a ~/.ssh/authorized_keys'
done

# Move RSA key to master -> first one is also the boot node and public masternode -> 
echo "move RSA key to masters"
for ((i=1; i < $NUM_MASTER; i++)); do
  # Prevent SSH identity prompts
  # If host IP exists in known hosts remove it
  ssh-keygen -R ${MASTER_IPS[i]}
  # Add host IP to known hosts
  ssh-keyscan -H ${MASTER_IPS[i]} | tee -a ~/.ssh/known_hosts
  
  # Copy over key (Will prompt for password)
  scp ~/.ssh/id_rsa.pub ${SSH_USER}@${MASTER_IPS[i]}:~/id_rsa.pub
  ssh ${SSH_USER}@${MASTER_IPS[i]} 'mkdir -p ~/.ssh; cat ~/id_rsa.pub | tee -a ~/.ssh/authorized_keys'
done

# Move RSA key to proxys
echo "move RSA key to proxies"
for ((i=0; i < $NUM_PROXY; i++)); do
  # Prevent SSH identity prompts
  # If host IP exists in known hosts remove it
  ssh-keygen -R ${PROXY_IPS[i]}
  # Add host IP to known hosts
  ssh-keyscan -H ${PROXY_IPS[i]} | tee -a ~/.ssh/known_hosts
  
  # Copy over key (Will prompt for password)
  scp ~/.ssh/id_rsa.pub ${SSH_USER}@${PROXY_IPS[i]}:~/id_rsa.pub
  ssh ${SSH_USER}@${PROXY_IPS[i]} 'mkdir -p ~/.ssh; cat ~/id_rsa.pub | tee -a ~/.ssh/authorized_keys'
done

# Move RSA key to Managementnodes
echo "move RSA key to managementnodes"
for ((i=0; i < $NUM_MANAGE; i++)); do
  # Prevent SSH identity prompts
  # If host IP exists in known hosts remove it
  ssh-keygen -R ${MANAGE_IPS[i]}
  # Add host IP to known hosts
  ssh-keyscan -H ${MANAGE_IPS[i]} | tee -a ~/.ssh/known_hosts
  
  # Copy over key (Will prompt for password)
  scp ~/.ssh/id_rsa.pub ${SSH_USER}@${MANAGE_IPS[i]}:~/id_rsa.pub
  ssh ${SSH_USER}@${MANAGE_IPS[i]} 'mkdir -p ~/.ssh; cat ~/id_rsa.pub | tee -a ~/.ssh/authorized_keys'
done

echo IdentityFile ~/.ssh/id_rsa | tee -a ~/.ssh/config
