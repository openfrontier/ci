#!/bin/bash
# Written by kfmaster <fuhaiou@hotmail.com>
# Initial written date: 2015-05-12
#
# Using etcd set variables and then using confd gernerate the docker-compose.yml and other files needed in this ci project
# This script contains 2 steps: 
# (1) prepare_environment: to install software pre-requisites, templates and project data files;
# (2) set_varibles_and_generate_config_files:  to set variables needed for this project and generate all configuration files;
#     by default, configuration files will be generated in /etc/confd/output/, you may change it in myci.conf;
#

confd_templates_dir=/etc/confd/templates
confd_conf_dir=/etc/confd/conf.d

project_config_dir=/etc/confd/output
project_postinstall_dir=${project_config_dir}/postinstall
project_data_dir=/etc/confd/data

function prepare_environment() {
# This script need etcdctl, confd, and docker-compose installed.
echo "(1) Check if etcdctl, confd and docker-compose is installed and a coreos/etcd container is running..."
echo

if [ ! -d /usr/local ]; then
    mkdir -p /usr/local
fi

# Download and install etcdctl if it does not exist on this server
if [ -x "/usr/bin/etcdctl" ]; then
    echo "etcdctl is available at: /usr/bin/etcdctl"
else
    curl -sL  https://github.com/coreos/etcd/releases/download/v2.1.0-alpha.0/etcd-v2.1.0-alpha.0-linux-amd64.tar.gz -o /usr/local/etcd-v2.1.0-alpha.0-linux-amd64.tar.gz
    cd /usr/local && tar xzf /usr/local/etcd-v2.1.0-alpha.0-linux-amd64.tar.gz
    chmod +x /usr/local/etcd-v2.1.0-alpha.0-linux-amd64/etcdctl
    ln -s /usr/local/etcd-v2.1.0-alpha.0-linux-amd64/etcdctl /usr/bin/etcdctl
fi

# Download and install confd if it does not exist on this server
if [ -x "/usr/bin/confd" ]; then
    echo "confd is available at: /usr/bin/confd"
else
    curl -sL https://github.com/kelseyhightower/confd/releases/download/v0.9.0/confd-0.9.0-linux-amd64 -o /usr/local/confd-0.9.0-linux-amd64
    chmod +x /usr/local/confd-0.9.0-linux-amd64
    ln -s /usr/local/confd-0.9.0-linux-amd64 /usr/bin/confd
fi

# Download and install docker-compose if it does not exist on this server
if [ -x "/usr/bin/docker-compose" ]; then
    echo "docker-compose is available at: /usr/bin/docker-compose"
else
    curl -sL https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/docker-compose
    chmod +x /usr/local/docker-compose
    ln -s /usr/local/docker-compose /usr/bin/docker-compose
fi

# Retrieve the docker-compose and nginx-proxy-conf template files and put them in ${confd_templates_dir} and ${confd_conf_dir}.
echo "Retrieving docker-compose template files"
mkdir -p ${confd_templates_dir} ${confd_conf_dir}

# Copy confd templates 
if [ -d ./confd-templates ]; then
    cp  ./confd-templates/* ${confd_templates_dir}/
else
    echo "Can not locate the confd-templates directory, please run myciSetup.sh from the same directory where the confd-templates directory exists."
    exit 1
fi

# Copy confd conf.d files 
if [ -d ./confd-conf.d ]; then
    cp  ./confd-conf.d/* ${confd_conf_dir}/
else
    echo "Can not locate the confd-conf.d directory, please run myciSetup.sh from the same directory where the confd-conf.d directory exists."
    exit 1
fi

# Start a sidekick container based on coreos/etcd to store user variables
echo
docker ps |grep -q coreos/etcd
if [ $? -eq 0 ]; then
    echo "There are coreos/etcd containers running, will try to use etcd listening on 127.0.0.1:4001 to store configuration variables."
else
    echo "Starting a coreos/etcd container to store configuration variables"
    docker run \
    -p 4001:4001 \
    -d coreos/etcd
    echo "Waiting 10 seconds for the etcd container to come up..."
    sleep 10
fi

echo
}

function set_varibles_and_generate_config_files() {
# First create naming spaces for etcd variables
# confd program will use config files in ${confd_templates_dir} and ${confd_conf_dir} to generate configuration files in the ${project_config_dir}.
echo "(2) Set variables using etcdctl and using confd to generate configuration files..."
echo
for svc in /services /services/datagerrit /services/datajenkins /services/pggerrit /services/gerrit /services/jenkins /services/pgredmine /services/redmine /services/nginxproxy
do
    etcdctl ls $svc 1> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        etcdctl mkdir $svc
    fi
done

if [ -e ./updateConf.sh ]; then
    bash ./updateConf.sh
else
    echo "Can't find updateConf.sh in current directory, please make sure you run from the current directory where myciSetup.sh and updateConf.sh exist."
    exit 1
fi
    
mypid=`pidof etcdctl`
# Check if there are etcdctl watch daemons running, if so, clean them up first
if [ ! -z ${mypid} ]; then
    pkill -9 etcdctl
    sleep 1
fi

# Start a new etcdctl watch daemon
(etcdctl exec-watch --recursive /services -- confd -onetime -backend etcd -node 127.0.0.1:4001 1>/dev/null 2>&1 &) &

echo "Please check if ${project_config_dir}/docker-compose.yml generated as expected and run docker-compoase against it."
echo "If all containers started and you can login Gerrit from your browser, run scripts in ${project_postinstall_dir} to import a demo project."
echo
}

prepare_environment
set_varibles_and_generate_config_files
