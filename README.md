# ICP-ee bash install for RHEL

This scripts are based on this recipe [ICP on RHEL] also my colleque Nik has provided scripts for ICP community edition: [NIK-ICP-CE].


A series of scripts to automate the installation of IBM Cloud Private-ee 2.1.0.3 on RHEL 7.5. 

The goals of this project are to:

- Create an easy automated repeatable install process for ICP
- Require little to no pre-requisties to run the ICP installation
- Create digestible snippets to facilitate understanding of the pre-reqs/install process of ICP

This project does not lay down any infrastructure, and expects you to have the required machines provisioned prior to beginning.

Instructions from the [pre-reqs doc](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/installing/prep_cluster.html) and [installation doc](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/installing/install_containers_CE.html). No steps labeled "optional" are taken

## System Requirements
This has been tested on RHEL 7.5

Requires sudo access (passwordless sudo will prevent some additional prompts).

Passwordless SSH from the master to all the workers is required. (see [./01-1-passwordless-ssh.sh](scripts/01-1-passwordless-ssh.sh))

### Hardware  
See [IBM Cloud Private Hardware Requirements](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/supported_system_config/hardware_reqs.html)

This has been tested with:

- Master Node - 4 CPUs, 8 GB RAM, 80 GB disk, public IP
- Worker Node(s) - 2 CPUs, 4 GB RAM, 40 GB disk

## Running the Scripts
1. Copy all script files to the VM that will be the master node of ICP
2. Fill in the variables in the script [./00-variables.sh](scripts/00-variables.sh))
3. (optional) If you need to set up passwordless-ssh review and run [./01-1-passwordless-ssh.sh](scripts/01-1-passwordless-ssh.sh)
4. (optional) If you wish to install on mounted storage, configure and run [./01-2-bind-mounts.sh](scripts/01-2-bind-mounts.sh)
5. Review and run each of the scripts in numeric order [01-update-hosts.sh](scripts/01-update-hosts.sh) through [09-kubeconfig.sh](scripts/09-kubeconfig.sh). Accept any ssh host identity prompts if they appear.

## Other projects
- https://github.com/IBM/deploy-ibm-cloud-private A more official installer. Contains a local Vagrant install or Terraform/Ansible installs for SoftLayer and OpenStack

## Dev Notes
Tasks on each of the workers are run in series (more wokers == more time), these tasks should be improved to run in parallel


[ICP on RHEL]: https://developer.ibm.com/recipes/tutorials/ibm-cloud-private-on-rhel/#r_step7
[NIK-ICP-CE]: https://github.com/niklaushirt/icp_rhel_installl
