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
mkdir -p /etc/confd/{templates,conf.d,output}
mkdir -p /etc/confd/output/postinstall
mkdir -p /etc/confd/data
for myfile in ci-docker-compose.tmpl ci-docker-compose.toml ci-nginx-proxy-conf.tmpl ci-nginx-proxy-conf.toml ci-setupContainer.tmpl ci-setupContainer.toml ci-importDemoProject.tmpl ci-importDemoProject.toml
do
    fileext=`echo ${myfile} |cut -d. -f2`
    if [ -e "./${myfile}" ]; then
        if [ "${fileext}" == "tmpl" ]; then
            cp ./${myfile} /etc/confd/templates/${myfile}
        else
            cp ./${myfile} /etc/confd/conf.d/${myfile}
        fi
    else
        echo "Can not locate ${myfile} in current directory, please put it in current directory."
    fi
done

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

# datagerrit service: this is a data conainter serving the gerrit container
printf "%-40s %s" "/services/datagerrit/image:"; etcdctl set /services/datagerrit/image kfmaster/datagerrit
printf "%-40s %s" "/services/datagerrit/name:" ; etcdctl set /services/datagerrit/name datagerrit

# datajenkins service: this is a data conainter serving the jenkins container
printf "%-40s %s" "/services/datajenkins/image:"; etcdctl set /services/datajenkins/image kfmaster/datajenkins
printf "%-40s %s" "/services/datajenkins/name: "; etcdctl set /services/datajenkins/name datajenkins

# pggerrit service: this is a postgres container serving the gerrit container
printf "%-40s %s" "/services/pggerrit/image:";  etcdctl set /services/pggerrit/image postgres
printf "%-40s %s" "/services/pggerrit/name:";   etcdctl set /services/pggerrit/name pg-gerrit
printf "%-40s %s" "/services/pggerrit/postgres_user:";      etcdctl set /services/pggerrit/postgres_user gerrit2
printf "%-40s %s" "/services/pggerrit/postgres_password:";  etcdctl set /services/pggerrit/postgres_password gerrit
printf "%-40s %s" "/services/pggerrit/postgres_db:";        etcdctl set /services/pggerrit/postgres_db reviewdb

# gerrit service: this is a gerrit container, the main Gerrit Code Review application
# please change the weburl, ldap_server and ldap_accountbase according to your environment

printf "%-40s %s" "/services/gerrit/image:"; etcdctl set /services/gerrit/image openfrontier/gerrit
printf "%-40s %s" "/services/gerrit/name:";  etcdctl set /services/gerrit/name gerrit
printf "%-40s %s" "/services/gerrit/database_type:";   etcdctl set /services/gerrit/database_type postgresql
printf "%-40s %s" "/services/gerrit/auth_type:";       etcdctl set /services/gerrit/auth_type LDAP
printf "%-40s %s" "/services/gerrit/httpd_listenurl:"; etcdctl set /services/gerrit/httpd_listenurl proxy-http://*:8080/gerrit

###############    MOST LIKELY NEED CHANGE     #################
printf "%-40s %s" "/services/gerrit/admin_uid:";         etcdctl set /services/gerrit/admin_uid gerrit
printf "%-40s %s" "/services/gerrit/admin_password:";    etcdctl set /services/gerrit/admin_password gerrit123
printf "%-40s %s" "/services/gerrit/admin_email:";       etcdctl set /services/gerrit/admin_email gerrit@example.com
printf "%-40s %s" "/services/gerrit/ssh_pubkey_file:";   etcdctl set /services/gerrit/ssh_pubkey_file ~/.ssh/id_rsa.pub
printf "%-40s %s" "/services/gerrit/host_ip:";           etcdctl set /services/gerrit/host_ip 192.168.0.200
printf "%-40s %s" "/services/gerrit/weburl:";            etcdctl set /services/gerrit/weburl http://192.168.0.200/gerrit
printf "%-40s %s" "/services/jenkins/weburl:";           etcdctl set /services/jenkins/weburl http://192.168.0.200/jenkins
printf "%-40s %s" "/services/redmine/weburl:";           etcdctl set /services/redmine/weburl http://192.168.0.200/redmine
printf "%-40s %s" "/services/gerrit/ldap_server:";       etcdctl set /services/gerrit/ldap_server 192.168.0.250
printf "%-40s %s" "/services/gerrit/ldap_accountbase:";  etcdctl set /services/gerrit/ldap_accountbase cn=users,cn=accounts,dc=example,dc=com
###############    MOST LIKELY NEED CHANGE     #################

# jenkins service: this is a jenkins container, the main Jenkins application
printf "%-40s %s" "/services/jenkins/image:"; etcdctl set /services/jenkins/image openfrontier/jenkins
printf "%-40s %s" "/services/jenkins/name:";  etcdctl set /services/jenkins/name jenkins
printf "%-40s %s" "/services/jenkins/opts:";  etcdctl set /services/jenkins/opts /jenkins

# pgredmine service: this is a postgres container, serving the redmine container
printf "%-40s %s" "/services/pgredmine/image:"; etcdctl set /services/pgredmine/image postgres
printf "%-40s %s" "/services/pgredmine/name:";  etcdctl set /services/pgredmine/name pg-redmine
printf "%-40s %s" "/services/pgredmine/postgres_user:";     etcdctl set /services/pgredmine/postgres_user redmine
printf "%-40s %s" "/services/pgredmine/postgres_password:"; etcdctl set /services/pgredmine/postgres_password redmine
printf "%-40s %s" "/services/pgredmine/postgres_db:";       etcdctl set /services/pgredmine/postgres_db redmine

# redmine service:  this is a redmine container, the main Redmine application
printf "%-40s %s" "/services/redmine/image:"; etcdctl set /services/redmine/image sameersbn/redmine
printf "%-40s %s" "/services/redmine/name:";  etcdctl set /services/redmine/name redmine
printf "%-40s %s" "/services/redmine/db_name:"; etcdctl set /services/redmine/db_name redmine
printf "%-40s %s" "/services/redmine/db_user:"; etcdctl set /services/redmine/db_user redmine
printf "%-40s %s" "/services/redmine/db_pass:"; etcdctl set /services/redmine/db_pass redmine
printf "%-40s %s" "/services/redmine/fetch_commits:";     etcdctl set /services/redmine/fetch_commits hourly
printf "%-40s %s" "/services/redmine/relative_url_root:"; etcdctl set /services/redmine/relative_url_root /redmine

# nginxproxy service: this is a nginx container, the main nginx reverse proxy application
printf "%-40s %s" "/services/nginxproxy/image:";   etcdctl set /services/nginxproxy/image nginx
printf "%-40s %s" "/services/nginxproxy/name:";    etcdctl set /services/nginxproxy/name nginx-proxy
printf "%-40s %s" "/services/nginxproxy/volumes:"; etcdctl set /services/nginxproxy/volumes /etc/confd/output/nginx-proxy.conf:/etc/nginx/conf.d/proxy.conf:ro

echo
}

function generate_config_file() {
# confd program will use config files in /etc/confd/{templates,conf.d} to generate the /etc/confd/output/docker-compose.yml file needed by this project
# Please check the files in /etc/confd/templates and /etc/confd/conf.d for more details
echo "(3) Using confd to gerenate a docker-compose.yml file in /etc/confd/output/"
echo

confd -onetime -backend etcd -node 127.0.0.1:4001
echo
echo "Please check if /etc/confd/output/docker-compose.yml generated as expected and run docker-compoase against it."
}

prepare_environment
set_varibles
generate_config_file
