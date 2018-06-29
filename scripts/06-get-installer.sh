#!/bin/bash

# Get the variables
source 00-variables.sh

# sudo docker pull ibmcom/icp-inception${INCEPTION_TAG}:2.1.0

echo "untaring " ~/ibm-cloud-private-$INCEPTION_TAG-$ICPVERSION.tar.gz " and loading into local docker registry"
tar xf ~/ibm-cloud-private-$INCEPTION_TAG-$ICPVERSION.tar.gz -O | sudo docker load

# for ((i=1; i < $NUM_MASTER; i++)); do
#   scp -i ${SSH_KEY} ~/ibm-cloud-private-$INCEPTION_TAG-$ICPVERSION.tar.gz ${SSH_USER}@${MASTER_HOSTNAMES[i]}:~/ibm-cloud-private-$INCEPTION_TAG-$ICPVERSION.tar.gz
#   ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'tar xf ~/ibm-cloud-private-x86_64-2.1.0.3.tar.gz -O | sudo docker load'
# done

sudo mkdir /opt/ibm-cloud-private-$ICPVERSION
sudo chown $USER /opt/ibm-cloud-private-$ICPVERSION
cd /opt/ibm-cloud-private-$ICPVERSION

echo "moving " ~/ibm-cloud-private-$INCEPTION_TAG-$ICPVERSION.tar.gz " to /opt/ibm-cloud-private-$ICPVERSION/cluster/images"
mkdir -p /opt/ibm-cloud-private-$ICPVERSION/cluster/images
mv ~/ibm-cloud-private-$INCEPTION_TAG-$ICPVERSION.tar.gz /opt/ibm-cloud-private-$ICPVERSION/cluster/images

echo "moving " ~/icp-docker-17.12.1_$INCEPTION_TAG.bin " to " /opt/ibm-cloud-private-$ICPVERSION/cluster/docker-engine
mkdir -p /opt/ibm-cloud-private-$ICPVERSION/cluster/docker-engine
mv ~/icp-docker-17.12.1_$INCEPTION_TAG.bin /opt/ibm-cloud-private-$ICPVERSION/cluster/docker-engine

# sudo docker run -v $(pwd):/data -e LICENSE=accept ibmcom/icp-inception${INCEPTION_TAG}:2.1.0 cp -r cluster /data
sudo docker run -v $(pwd):/data -e LICENSE=accept ibmcom/icp-inception:$ICPVERSION-ee cp -r cluster /data
