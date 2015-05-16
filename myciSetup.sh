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

CONFD_TEMPLATES_DIR=/etc/confd/templates
CONFD_CONF_DIR=/etc/confd/conf.d

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

echo
}

function set_varibles_and_generate_config_files() {
echo "(2) Set variables using etcdctl and using confd to generate configuration files..."
echo

# Most procedures for gernerating and updating confd config files are in the updateConf.sh
if [ -e ./updateConf.sh ]; then
    bash ./updateConf.sh
else
    echo "Can't find updateConf.sh in current directory, please make sure you run from the current directory where myciSetup.sh and updateConf.sh exist."
    exit 1
fi
    
# Check if there are etcdctl watch daemons running, if so, clean them up first, then start a etcd watch daemon
mypid=`pidof etcdctl`
if [ ! -z ${mypid} ]; then
    pkill -9 etcdctl
    sleep 1
fi

# Start a new etcdctl watch daemon
(etcdctl exec-watch --recursive /services -- confd -onetime -backend etcd -node 127.0.0.1:4001 1>/dev/null 2>&1 &) &

}

function start_and_config_containers {
# Get the project_config_dir and project_postinstall_dir again in case they have changed.
project_config_dir=$(etcdctl get /services/myci/project_config_dir)
project_postinstall_dir=${project_config_dir}/postinstall
project_gerrit_weburl="$(etcdctl get /services/gerrit/weburl)"
project_jenkins_weburl="$(etcdctl get /services/jenkins/weburl)"
project_redmine_weburl="$(etcdctl get /services/redmine/weburl)"
project_gerrit_admin_uid=$(etcdctl get /services/gerrit/admin_uid)
project_gerrit_admin_password=$(etcdctl get /services/gerrit/admin_password)

function check_container_status {
# Check containers status
mystatus=$(docker-compose -f ${project_config_dir}/docker-compose.yml ps |grep -v "\-\-\-\-\-\-" |grep -v State |grep -v Up)
if [ ! -z ${mystatus} ]; then
    echo ${mystatus}
    echo "Some containers did not start or restart properly, please use docker ps -a to troubleshoot further..."
    exit 1
fi
}

echo
# First double-check all config files are generated
if [ ! -e ${project_config_dir}/docker-compose.yml ]; then
    echo "It seems the docker-compose.yml configuration file is not generated correctly, please troubleshoot... "
    exit 1
fi

for myscript in S00setupContainer.sh  S01importDemoProject.sh
do
    if [ ! -e ${project_postinstall_dir}/${myscript} ]; then
        echo "It seems the ${myscript} script is not generated correctly, please troubleshoot... "
        exit 1
    fi
done

# Prompt user to see if they want to start all containers
while true  
do  
    read -n1 -p "Do you want to start all containers in myci service now? [Y/n] " response
    echo 
    case "$response" in
        y|Y) echo "Starting all containers in myci service..." 
             echo
             echo "docker-compose -f ${project_config_dir}/docker-compose.yml up -d"
             echo
             docker-compose -f ${project_config_dir}/docker-compose.yml up -d
             echo
             echo "Wait for 1 minute to let all containers start properly..."
             echo
             sleep 60
             break 
             ;; 
        n|N) echo
             echo -e "Ok. You can run docker-compose manually against the ${project_config_dir}/docker-compose.yml  file later."
             echo
             exit 1 
             ;; 
        *)   echo
             echo "Invalid option given." 
             ;;
    esac
done

check_container_status
echo "You can check ${project_gerrit_weburl} for Gerrit, try to login as ${project_gerrit_admin_uid} / ${project_gerrit_admin_password}"
echo "If you can't login, please do not run following postinstall scripts, and troubleshoot your LDAP setting and make sure above user/password works in your LDAP."
echo

# Prompt user to see if they want to run S00setupContainer.sh
while true  
do  
    read -n1 -p "Do you want to run ${project_postinstall_dir}/S00setupContainer.sh to setup initial users and link Gerrit and Jenkins now? [Y/n] " response
    case "$response" in
        y|Y)    echo 
                echo "Setup inital users in Gerrit and Jenkins containers..." 
                echo
                echo "bash ${project_postinstall_dir}/S00setupContainer.sh"
                echo
                bash ${project_postinstall_dir}/S00setupContainer.sh
                echo
                echo "Wait for 30 seconds for the S00setupContainer.sh to finish correctly..."
                sleep 30
                break 
                ;; 
        n|N)    echo
                echo -e "Ok. You can run ${project_postinstall_dir}/S00setupContainer.sh script manually later."
                echo
                exit 1 
                ;; 
        *)      echo
                echo "Invalid option given." 
                ;;
    esac
done

check_container_status
echo "You can check ${project_gerrit_weburl} for Gerrit and  ${project_jenkins_weburl} for Jenkins;"
echo

# Prompt user to see if they want to run S01importDemoProject.sh
while true  
do
    read -n1 -p "Do you want to run ${project_postinstall_dir}/S01importDemoProject.sh to import a demo project now? [Y/n] " response
    echo 
    case "$response" in
        y|Y)    echo
                echo "Import a demo project now..." 
                echo
                echo "bash ${project_postinstall_dir}/S01importDemoProject.sh"
                echo
                bash ${project_postinstall_dir}/S01importDemoProject.sh
                echo
                break 
                ;;
        n|N)    echo
                echo -e "Ok. You can run ${project_postinstall_dir}/S01importDemoProject.sh script manually later."
                echo
                exit 1
                ;;
        *)      echo
                echo "Invalid option given." 
                ;;
    esac
done

check_container_status
echo "You can check ${project_gerrit_weburl} for Gerrit,  ${project_jenkins_weburl} for Jenkins, and ${project_redmine_weburl} for Redmine;"
echo

}

prepare_environment
set_varibles_and_generate_config_files
start_and_config_containers 
