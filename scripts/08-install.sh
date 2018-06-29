#!/bin/bash

# Get the variables
source 00-variables.sh

# cp ~/icp-docker-17.12.1_x86_64.bin /opt/ibm-cloud-private-$ICPVERSION/cluster/
cd /opt/ibm-cloud-private-$ICPVERSION/cluster

sudo docker run -e LICENSE=accept --net=host -t -v "$(pwd)":/installer/cluster ibmcom/icp-inception:$ICPVERSION-ee install
