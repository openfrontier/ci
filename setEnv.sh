#!/bin/bash
# Written by kfmaster <fuhaiou@hotmail.com>
# Initial written date: 2015-05-12
#
# Using etcd set variables used by confd to gernerate the docker-compose.yml file for the ci project
# This script contains 3 steps: 
# (1) prepare_environment: to install pre-requisites software and config files;
# (2) set_varibles:  to set variables needed for this project;
# (3) generate_config_file:  to generate a /etc/confd/conf.d/docker-compose.yml file for this project;
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

# Retrieve the docker-compose template files and put them in /etc/confd/{templates,conf.d} 
echo "Retrieving docker-compose template files"
mkdir -p /etc/confd/{templates,conf.d}
for myfile in docker-compose.yml.example docker-compose.tmpl docker-compose.toml
do
if [ -e "./${myfile}" ]; then
    if [ "${myfile}" == "docker-compose.tmpl" ]; then
        cp ./${myfile} /etc/confd/templates/${myfile}
    else
        cp ./${myfile} /etc/confd/conf.d/${myfile}
    fi
else
    echo "Can not locate ${myfile} in current directory, please put it in current directory."
fi
done


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

# datagerrit service: this is a data conainter serving the gerrit container
etcdctl set /services/datagerrit/image kfmaster/datagerrit
etcdctl set /services/datagerrit/name datagerrit

# datajenkins service: this is a data conainter serving the jenkins container
etcdctl set /services/datajenkins/image kfmaster/datajenkins
etcdctl set /services/datajenkins/name datajenkins

# pggerrit service: this is a postgres container serving the gerrit container
etcdctl set /services/pggerrit/image postgres
etcdctl set /services/pggerrit/name pg-gerrit
etcdctl set /services/pggerrit/postgres_user gerrit2
etcdctl set /services/pggerrit/postgres_password gerrit
etcdctl set /services/pggerrit/postgres_db reviewdb

# gerrit service: this is a gerrit container, the main Gerrit Code Review application
# please change the weburl, ldap_server and ldap_accountbase according to your environment

etcdctl set /services/gerrit/image openfrontier/gerrit
etcdctl set /services/gerrit/name gerrit
etcdctl set /services/gerrit/weburl http://192.168.1.141/gerrit
etcdctl set /services/gerrit/httpd_listenurl proxy-http://*:8080/gerrit
etcdctl set /services/gerrit/database_type postgresql
etcdctl set /services/gerrit/auth_type LDAP
etcdctl set /services/gerrit/ldap_server 192.168.1.250
etcdctl set /services/gerrit/ldap_accountbase cn=users,cn=accounts,dc=pod0,dc=nethsd,dc=net

# jenkins service: this is a jenkins container, the main Jenkins application
etcdctl set /services/jenkins/image openfrontier/jenkins
etcdctl set /services/jenkins/name jenkins
etcdctl set /services/jenkins/opts /jenkins

# pgredmine service: this is a postgres container, serving the redmine container
etcdctl set /services/pgredmine/image postgres
etcdctl set /services/pgredmine/name pg-redmine
etcdctl set /services/pgredmine/postgres_user redmine
etcdctl set /services/pgredmine/postgres_password redmine
etcdctl set /services/pgredmine/postgres_db redmine

# redmine service:  this is a redmine container, the main Redmine application
etcdctl set /services/redmine/image sameersbn/redmine
etcdctl set /services/redmine/name redmine
etcdctl set /services/redmine/db_name redmine
etcdctl set /services/redmine/db_user redmine
etcdctl set /services/redmine/db_pass redmine
etcdctl set /services/redmine/redmin_relative_url_root /redmine
etcdctl set /services/redmine/redmin_fetch_commits hourly
etcdctl set /services/redmine/image sameersbn/redmine

# nginxproxy service: this is a nginx container, the main nginx reverse proxy application
etcdctl set /services/nginxproxy/image nginx
etcdctl set /services/nginxproxy/name nginx-proxy
etcdctl set /services/nginxproxy/volumes ~/nginx-docker/proxy.conf:/etc/nginx/conf.d/proxy.conf:ro
echo
}

function generate_config_file() {
# confd program will use config files in /etc/confd/{templates,conf.d} to generate the /tmp/docker-compose.yml file needed by this project
# Please check the files in /etc/confd/templates and /etc/confd/conf.d for more details
echo "(3) Using confd to gerenate a docker-compose.yml file in /tmp."
echo

confd -onetime -backend etcd -node 127.0.0.1:4001
echo
echo "Please check if /tmp/docker-compose.yml generated as expected and run docker-compoase against it."
}

prepare_environment
set_varibles
generate_config_file
