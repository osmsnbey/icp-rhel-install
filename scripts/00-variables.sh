#!/bin/bash
# ----------------------------------------------------------------------------------------------------\\
# Description:
#   A basic installer for IBM Cloud Private-EE 2.1.0.3 on RHEL 7.5
#   based on sripts from https://github.com/jcantosz/icp-rhel-install.git 
#   expanded to multinode and 
# ----------------------------------------------------------------------------------------------------\\
# Note:
#   This assumes all VMs were provisioned to be accessable with the same SSH key
#   All scripts should be run from the master node
# ----------------------------------------------------------------------------------------------------\\
# System Requirements:
#   Tested against RHEL 7.5 
#   3 Master Node - 4 CPUs, 8 GB RAM, 250 GB disk, public IP
#   3 Worker Node - 2 CPUs, 4 GB RAM, 250 GB disk
#   Requires sudo access
# ----------------------------------------------------------------------------------------------------\\
# Docs:
#   Installation Steps From:
#    - https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/installing/prep_cluster.html
#    - https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/installing/install_containers_CE.html
#
#   Wiki:
#    - https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W1559b1be149d_43b0_881e_9783f38faaff
#    - https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W1559b1be149d_43b0_881e_9783f38faaff/page/Connect
# ----------------------------------------------------------------------------------------------------\\

export ICPVERSION=2.1.0.3

export SSH_KEY=~/.ssh/id_rsa
export SSH_USER=root
export SSH_PASSWD=""

# inet-proxy YES or NO
# https://medium.com/ibm-cloud/ibm-cloud-private-behind-a-proxy-633d6e66021
export USE_INET_PROXY="NO"
export ICP_HTTP_PROXY="http://1.2.3.4:8080" 
export ICP_HTTPS_PROXY="http://1.2.3.4:8080"
# export ICP_NO_PROXY="localhost,127.0.0.1,mycluster.icp,192.168.1.0/24"
export ICP_NO_PROXY="localhost,127.0.0.1"
export ICP_CLUSTER_NAME="mycluster.icp"
export ICP_IP_RANGE="192.168.1.0/24"
export ICP_SERVICE_IP_RANGE="192.168.0.1/24"

export PUBLIC_IP=01.02.03.04
export MASTER_IP=192.168.198.17

# MASTER_IPS[0] should be the same master at MASTER_HOSTNAMES[0]
export MASTER_IPS=("192.168.198.17" "192.168.217.218" "192.168.217.220" )
export MASTER_HOSTNAMES=("icprhel1.mycluster.icp" "icprhel2.mycluster.icp" "icprhel3.mycluster.icp")
export MASTER_HOSTNAMES_SHORT=("icprhel1" "icprhel2" "icprhel3")

if [[ "${#MASTER_IPS[@]}" != "${#MASTER_HOSTNAMES[@]}" ]]; then
  echo "ERROR: Ensure that the arrays MASTER_IPS and MASTER_HOSTNAMES are of the same length"
  return 1
fi

export NUM_MASTER=${#MASTER_IPS[@]}

# WORKER_IPS[0] should be the same worker at WORKER_HOSTNAMES[0]
export WORKER_IPS=("192.168.218.44" "192.168.218.55" "192.168.218.58")
export WORKER_HOSTNAMES=("icprhel4.mycluster.icp" "icprhel5.mycluster.icp" "icprhel6.mycluster.icp")
export WORKER_HOSTNAMES_SHORT=("icprhel4" "icprhel5" "icprhel6")

if [[ "${#WORKER_IPS[@]}" != "${#WORKER_HOSTNAMES[@]}" ]]; then
  echo "ERROR: Ensure that the arrays WORKER_IPS and WORKER_HOSTNAMES are of the same length"
  return 1
fi

export NUM_WORKERS=${#WORKER_IPS[@]}


# if separate proxys will be used add them here, if not every master will be also be a proxy
# PROXY_IPS[0] should be the same proxy at PROXY_HOSTNAMES[0]
export PROXY_IPS=("")
export PROXY_HOSTNAMES=("")
export PROXY_HOSTNAMES_SHORT=("")
if [[ "${#PROXY_IPS[@]}" != "${#PROXY_HOSTNAMES[@]}" ]]; then
  echo "ERROR: Ensure that the arraysPROXY_IPS and PROXY_HOSTNAMES are of the same length"
  return 1
fi
if [$PROXY_IPS = ""]; then
  export NUM_PROXY=0
else
  export NUM_PROXY=${#PROXY_IPS[@]}
fi

# if manage nodes are used add them here
# MANAGE_IPS[0] should be the same manage node at MANAGE_HOSTNAMES[0]
export MANAGE_IPS=("")
export MANAGE_HOSTNAMES=("")
export MANAGE_HOSTNAMES_SHORT=("")
if [[ "${#MANAGE_IPS[@]}" != "${#MANAGE_HOSTNAMES[@]}" ]]; then
  echo "ERROR: Ensure that the arrays MANAGE_IPS and MANAGE_HOSTNAMES are of the same length"
  return 1
fi
if [$MANAGE_IPS = ""]; then
  export NUM_MANAGE=0
else
  export NUM_MANAGE=${#MANAGE_IPS[@]}
fi


export ARCH="$(uname -m)"
export INCEPTION_TAG="$(uname -m)"
if [ "${ARCH}" != "x86_64" ]; then
  export INCEPTION_TAG="${ARCH}"
fi

 #DEBUG - print out Master & Worker nodes
 echo "setting environment variables"
 echo "============================="
 echo "#Master = " ${NUM_MASTER} " #Worker = " ${NUM_WORKERS} " #Proxy = " ${NUM_PROXY} " #ManagementNodes = " ${NUM_MANAGE} 
 echo "---------------------------------------------------------------"
 echo "MASTER_Hostname - IP"
 export ARRAY_IDX1=${!MASTER_IPS[*]}
 for index in $ARRAY_IDX1;
 do
     echo ${MASTER_HOSTNAMES[$index]} "-" ${MASTER_IPS[$index]}
 done

# echo "WORKER_Hostname - IP"
# export ARRAY_IDX=${!WORKER_IPS[*]}
# for index in $ARRAY_IDX;
# do
#     echo ${WORKER_HOSTNAMES[$index]} "-" ${WORKER_IPS[$index]}
# done
