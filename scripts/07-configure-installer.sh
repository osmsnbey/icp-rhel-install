#!/bin/bash

# Get the variables
source 00-variables.sh

# Move SSH key
sudo cp ~/.ssh/master.id_rsa /opt/ibm-cloud-private-$ICPVERSION/cluster/ssh_key

# Configure hosts
echo "[master]" | sudo tee /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
# echo "${MASTER_IP}" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
# echo "" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
for ((i=0; i < $NUM_MASTER; i++)); do
  echo ${MASTER_IPS[i]} | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
done
echo "" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts


echo "[worker]" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
for ((i=0; i < $NUM_WORKERS; i++)); do
  echo ${WORKER_IPS[i]} | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
done
echo "" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts

echo "[proxy]" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
#echo "${MASTER_IP}" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
n=$NUM_PROXY
if [ "$n" -eq "0" ]; then
  echo "all master nodes are also proxy nodes"
  export NUM_PROXY="${NUM_MASTER}"
  export PROXY_IPS=( "${MASTER_IPS[@]}" )
fi
for ((i=0; i < $NUM_PROXY; i++)); do
  echo ${PROXY_IPS[i]} | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
done
echo "" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts

if [ "$NUM_MANAGE" -gt "0" ]; then
  echo "management nodes will be used"
  echo "[management]" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
  for ((i=0; i < $NUM_MANAGE; i++)); do
    echo ${MANAGE_IPS[i]} | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
  done
  echo "" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
fi

# Add line for external IP in config
echo "cluster_access_ip: ${PUBLIC_IP}" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/config.yaml
echo "proxy_access_ip: ${PUBLIC_IP}" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/config.yaml

# set tiller_http/s proxy settings if needed
if [ $USE_INET_PROXY = "YES" ]; then
  echo "### set inet-proxy settings for tiller"
  echo "tiller_http_proxy: ${ICP_HTTP_PROXY}" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/config.yaml
  echo "tiller_https_proxy: ${ICP_HTTPS_PROXY}" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/config.yaml
  echo "" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts
  echo "" | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/hosts

  echo "### set inet-proxy settings for docker"
  dockerenv='docker_env: ["HTTP_PROXY='${ICP_HTTP_PROXY}'","HTTPS_PROXY='${ICP_HTTPS_PROXY}'","NO_PROXY='${ICP_NO_PROXY}','${ICP_CLUSTER_NAME}','${ICP_IP_RANGE}'"]'
  echo ${dockerenv} | sudo tee -a /opt/ibm-cloud-private-$ICPVERSION/cluster/config.yaml
fi

### set Kubernetes IPv4 network address range
# https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.3/installing/config_yaml.html
## Network in IPv4 CIDR format
#network_cidr: 10.1.0.0/16    --> ICP_IP_RANGE
## Kubernetes Settings
#service_cluster_ip_range: 10.0.0.1/24 --> ICP_SERVICE_IP_RANGE