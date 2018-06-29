#!/bin/bash

# Get the variables
source 00-variables.sh

# Must have yum configured on all hosts prior to running this step

#TODO: Make theses steps run in parallel

# Install docker & python on boot/master
sudo yum upgrade -y
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 socat
# if [ "$ARCH" == "ppc64le" ]; then
#   # https://developer.ibm.com/linuxonpower/docker-on-power/
#   echo -e "[docker]\nname=Docker\nbaseurl=http://ftp.unicamp.br/pub/ppc64el/rhel/7/docker-ppc64el/\nenabled=1\ngpgcheck=0\n" | sudo tee /etc/yum.repos.d/docker.repo
# else
#   sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# fi
# sudo yum update -y
# sudo yum install -y docker-ce

# Fall back to pinned version (no fallback for ppc)
# if [ "$?" == "1" ]; then
#   yum install --setopt=obsoletes=0 -y docker-ce-17.12.1.ce-1.el7.centos.x86_64 docker-ce-selinux-17.12.1.ce-1.el7.centos.noarch
# fi
sudo chmod +x ~/icp-docker-17.12.1_x86_64.bin
~/icp-docker-17.12.1_x86_64.bin --install

sudo yum install -y python-setuptools
sudo easy_install pip

# prepare docker for inet-proxy configuration
if [$USE_INET_PROXY = "YES"]; then
  echo "setting up iNet Proxy for Docker"
  sudo mkdir -p /etc/systemd/system/docker.service.d
  sudo cp ~/scripts/configfiles/http-proxy.conf /etc/systemd/system/docker.service.d
fi

sudo systemctl daemon-reload
sudo systemctl restart docker


for ((i=1; i < $NUM_MASTER; i++)); do
  # Install docker & python on worker
  echo "SSH " ${SSH_USER}@${MASTER_HOSTNAMES[i]}
  ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo yum upgrade -y
  ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo yum install -y yum-utils device-mapper-persistent-data lvm2 socat


  # if [ "$ARCH" == "ppc64le" ]; then
  #   ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'echo -e "[docker]\nname=Docker\nbaseurl=http://ftp.unicamp.br/pub/ppc64el/rhel/7/docker-ppc64el/\nenabled=1\ngpgcheck=0\n" | sudo tee /etc/yum.repos.d/docker.repo'
  # else
  #   ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  # fi
  
  # ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo yum update -y
  # ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo yum install -y docker-ce

  # Fall back to pinned version (no fallback for ppc)
  # if [ "$?" == "1" ]; then
  #   ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} yum install --setopt=obsoletes=0 -y docker-ce-17.03.2.ce-1.el7.centos.x86_64 docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch
  # fi

  sudo scp -i ${SSH_KEY} ~/icp-docker-17.12.1_x86_64.bin  ${SSH_USER}@${MASTER_HOSTNAMES[i]}:~/icp-docker-17.12.1_x86_64.bin
  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo chmod +x ~/icp-docker-17.12.1_x86_64.bin && sudo ~/icp-docker-17.12.1_x86_64.bin --install'
  if [$USE_INET_PROXY = "YES"]; then
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo mkdir -p /etc/systemd/system/docker.service.d'
    sudo scp -i ${SSH_KEY} ~/scripts/configfiles/http-proxy.conf ${SSH_USER}@${MASTER_HOSTNAMES[i]}:/etc/systemd/system/docker.service.d
  fi

  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo systemctl daemon-reload'
  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo systemctl restart docker'

  ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo yum install -y python-setuptools
  ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo easy_install pip
done


for ((i=0; i < $NUM_WORKERS; i++)); do
  # Install docker & python on worker
   echo "SSH " ${SSH_USER}@${WORKER_HOSTNAMES[i]}
  ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo yum upgrade -y
  ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo yum install -y yum-utils device-mapper-persistent-data lvm2 socat


  sudo scp -i ${SSH_KEY} ~/icp-docker-17.12.1_x86_64.bin  ${SSH_USER}@${WORKER_HOSTNAMES[i]}:~/icp-docker-17.12.1_x86_64.bin
  ssh -i ${SSH_KEY} ${SSH_USER}@${WORKER_HOSTNAMES[i]} 'sudo chmod +x ~/icp-docker-17.12.1_x86_64.bin && sudo ~/icp-docker-17.12.1_x86_64.bin --install'

  if [$USE_INET_PROXY = "YES"]; then
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo mkdir -p /etc/systemd/system/docker.service.d'
    sudo scp -i ${SSH_KEY} ~/scripts/configfiles/http-proxy.conf ${SSH_USER}@${MASTER_HOSTNAMES[i]}:/etc/systemd/system/docker.service.d
  fi

  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo systemctl daemon-reload'
  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo systemctl restart docker'
  
  ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo yum install -y python-setuptools
  ssh ${SSH_USER}@${WORKER_HOSTNAMES[i]} sudo easy_install pip
done


for ((i=0; i < $NUM_PROXY; i++)); do
  # Install docker & python on PROXY
  echo "SSH " ${SSH_USER}@${PROXY_HOSTNAMES[i]}
  ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo yum upgrade -y  
  ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo yum install -y yum-utils device-mapper-persistent-data lvm2 socat


  sudo scp -i ${SSH_KEY} ~/icp-docker-17.12.1_x86_64.bin  ${SSH_USER}@${PROXY_HOSTNAMES[i]}:~/icp-docker-17.12.1_x86_64.bin
  ssh -i ${SSH_KEY} ${SSH_USER}@${PROXY_HOSTNAMES[i]} 'sudo chmod +x ~/icp-docker-17.12.1_x86_64.bin && sudo ~/icp-docker-17.12.1_x86_64.bin --install'

  if [$USE_INET_PROXY = "YES"]; then
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo mkdir -p /etc/systemd/system/docker.service.d'
    sudo scp -i ${SSH_KEY} ~/scripts/configfiles/http-proxy.conf ${SSH_USER}@${MASTER_HOSTNAMES[i]}:/etc/systemd/system/docker.service.d
  fi

  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo systemctl daemon-reload'
  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo systemctl restart docker'
  
  ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo yum install -y python-setuptools
  ssh ${SSH_USER}@${PROXY_HOSTNAMES[i]} sudo easy_install pip
done

for ((i=0; i < $NUM_MANAGE; i++)); do
  # Install docker & python on MANAGE
  echo "SSH " ${SSH_USER}@${MANAGE_HOSTNAMES[i]}
  ssh ${SSH_USER}@${MASTER_HOSTNAMES[i]} sudo yum upgrade -y
  ssh ${SSH_USER}@${MANAGE_HOSTNAMES[i]} sudo yum install -y yum-utils device-mapper-persistent-data lvm2 socat

  sudo scp -i ${SSH_KEY} ~/icp-docker-17.12.1_x86_64.bin  ${SSH_USER}@${MANAGE_HOSTNAMES[i]}:~/icp-docker-17.12.1_x86_64.bin
  ssh -i ${SSH_KEY} ${SSH_USER}@${MANAGE_HOSTNAMES[i]} 'sudo chmod +x ~/icp-docker-17.12.1_x86_64.bin && sudo ~/icp-docker-17.12.1_x86_64.bin --install'
  
  if [$USE_INET_PROXY = "YES"]; then
    ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo mkdir -p /etc/systemd/system/docker.service.d'
    sudo scp -i ${SSH_KEY} ~/scripts/configfiles/http-proxy.conf ${SSH_USER}@${MASTER_HOSTNAMES[i]}:/etc/systemd/system/docker.service.d
  fi

  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo systemctl daemon-reload'
  ssh -i ${SSH_KEY} ${SSH_USER}@${MASTER_HOSTNAMES[i]} 'sudo systemctl restart docker'
  
  ssh ${SSH_USER}@${MANAGE_HOSTNAMES[i]} sudo yum install -y python-setuptools
  ssh ${SSH_USER}@${MANAGE_HOSTNAMES[i]} sudo easy_install pip
done