#!/bin/bash
# Written by kfmaster <fuhaiou@hotmail.com>
# Initial written date: 2015-05-12
#
# Using etcd set variables used by confd to gernerate the docker-compose.yml file for the ci project
# This script contains 3 steps: 
# (1) prepare_environment: to install pre-requisites software and config files;
# (2) set_varibles:  to set variables needed for this project;
# (3) generate_config_file:  to generate a /etc/confd/output/docker-compose.yml file for this project;
#

function prepare_environment() {
# This script need etcdctl, confd, and docker-compose installed.
echo "(1) Check if etcdctl, confd and docker-compoase is installed and a new coreos/etcd container is running..."
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

# Retrieve the docker-compose and nginx-proxy-conf template files and put them in /etc/confd/{templates,conf.d} 
echo "Retrieving docker-compose template files"
mkdir -p /etc/confd/{templates,conf.d}
mkdir -p /etc/confd/{output,data}
mkdir -p /etc/confd/output/postinstall

# Copy confd templates 
if [ -d ./confd-templates ]; then
    cp  ./confd-templates/* /etc/confd/templates/
else
    echo "Can not locate the confd-templates directory, please copy it to current directory."
fi

# Copy confd conf.d files 
if [ -d ./confd-conf.d ]; then
    cp  ./confd-conf.d/* /etc/confd/conf.d/
else
    echo "Can not locate the confd-conf.d directory, please copy it to current directory."
fi

# Copy demo project data
if [ -d ./demoProject01 ]; then
    cp -r ./demoProject01 /etc/confd/data/
else
    echo "Can not locate the demoProject01 directory, please copy it to current directory."
fi


# Start a sidekick container based on coreos/etcd to store user variables
echo
docker ps |grep -q coreos/etcd
if [ $? -eq 0 ]; then
    echo "There are coreos/etcd containers running, stop them to begin fresh"
    docker ps |grep coreos/etcd |awk '{print $1}' |xargs docker stop
fi

echo "Straring a coreos/etcd container to store variables"
docker run \
-p 4001:4001 \
-d coreos/etcd

echo "Waiting 10 seconds for the etcd container to come up..."
sleep 10
echo
}

function set_varibles() {
# First create naming spaces for etcd variables
echo "(2) Set variables using etcdctl ..."
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
fi
    
echo
}

function generate_config_file() {
# confd program will use config files in /etc/confd/{templates,conf.d} to generate the /etc/confd/output/docker-compose.yml file needed by this project
# Please check the files in /etc/confd/templates and /etc/confd/conf.d for more details
echo "(3) Using confd to gerenate a docker-compose.yml file in /etc/confd/output/"

#confd -onetime -backend etcd -node 127.0.0.1:4001
echo
echo "Please check if /etc/confd/output/docker-compose.yml generated as expected and run docker-compoase against it."
echo "If all containers started and you can login Gerrit from your browser, run scripts in /etc/confd/output/postinstall/ to import a demo project."
}

prepare_environment
set_varibles
generate_config_file
