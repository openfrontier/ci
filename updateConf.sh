#!/bin/bash

CONFD_TEMPLATES_DIR=/etc/confd/templates
CONFD_CONF_DIR=/etc/confd/conf.d

project_config_dir=/etc/confd/output
project_postinstall_dir=${project_config_dir}/postinstall
project_data_dir=/etc/confd/data

# Retrieve the docker-compose and nginx-proxy-conf template files and put them in ${CONFD_TEMPLATES_DIR} and ${CONFD_CONF_DIR}.
echo "Retrieving confd template resource files"
if [ ! -d ${CONFD_TEMPLATES_DIR} ]; then
    mkdir -p ${CONFD_TEMPLATES_DIR} 
fi

if [ ! -d ${CONFD_CONF_DIR} ]; then
    mkdir -p ${CONFD_CONF_DIR} 
fi


# Copy confd templates 
if [ -d ./confd-templates ]; then
    cp  ./confd-templates/* ${CONFD_TEMPLATES_DIR}/
else
    echo "Can not locate the confd-templates directory, please run myciSetup.sh from the same directory where the confd-templates directory exists."
    exit 1
fi

# Copy confd conf.d files 
if [ -d ./confd-conf.d ]; then
    cp  ./confd-conf.d/* ${CONFD_CONF_DIR}/
else
    echo "Can not locate the confd-conf.d directory, please run myciSetup.sh from the same directory where the confd-conf.d directory exists."
    exit 1
fi

# Start a sidekick container based on coreos/etcd to store user variables if etcd is not running
docker ps |grep -q coreos/etcd
if [ $? -eq 0 ]; then
    echo "There is a coreos/etcd container running, will try to use etcd listening on 127.0.0.1:4001 to store configuration variables."
else
    echo "Starting a coreos/etcd container to store configuration variables"
    docker run \
    -p 4001:4001 \
    -d coreos/etcd
    echo "Waiting 10 seconds for the etcd container to come up..."
    sleep 10
fi

# First create naming spaces for etcd variables
# confd program will use config files in ${CONFD_TEMPLATES_DIR} and ${CONFD_CONF_DIR} to generate configuration files in the ${project_config_dir}.
for svc in /services /services/myci /services/datagerrit /services/datajenkins /services/pggerrit /services/gerrit /services/jenkins /services/pgredmine /services/redmine /services/nginxproxy
do
    etcdctl ls $svc 1> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        etcdctl mkdir $svc
    fi
done


# Gernerate a temporary script for setting etcd key/value pairs based on myci.conf
outfile1=tmp1_etcdctl.sh
outfile2=tmp2_etcdctl.sh
cd ~
touch ${outfile1}
touch ${outfile2}
cd - 1>/dev/null

if [ -e ./myci.conf ]; then
    grep -v "^#" ./myci.conf |grep -v "^#" | awk '{print "etcdctl set",$1,$2}' > ~/${outfile1}
else
    echo "Can't fine setEnv.conf in current directory, please place it in `pwd`"
    exit 1
fi

# Set project environment variables before generating/updating other configuration files.
grep "/services/myci/project" ./myci.conf |awk '{print "etcdctl set",$1,$2}' > ~/${outfile2}
bash ~/${outfile2} 1>/dev/null 2>&1
project_config_dir=`etcdctl get /services/myci/project_config_dir`
project_postinstall_dir=${project_config_dir}/postinstall
project_data_dir=`etcdctl get /services/myci/project_data_dir`

mkdir -p ${project_config_dir} 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Directory ${project_config_dir} can not be created, please troubleshoot."
    exit 1
fi

mkdir -p ${project_postinstall_dir} 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Directory ${project_postinstall_dir} can not be created, please troubleshoot."
    exit 1
fi

mkdir -p ${project_data_dir} 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Directory ${project_data_dir} can not be created, please troubleshoot."
    exit 1
fi

# Fix output directory manually if they changed from their default values.
# new_config_dir is needed to escap the leading / in directory path.
if [ ! "${project_config_dir}" == "/etc/confd/output" ]; then
    new_config_dir=$(echo ${project_config_dir} | sed 's/\//\\\//g')
    for mytoml in `ls /etc/confd/conf.d/*.toml`
    do
        if [ -e ${mytoml} ]; then
            sed -i.bak -e 's/\/etc\/confd\/output/'"${new_config_dir}"'/' ${mytoml}
        else
            echo "Can't find ${mytoml}, please troubleshoot."
            exit 1
        fi
    done
fi

# Copy demo project data to ${project_data_dir} if it has not been done.
if [ ! -d ${project_data_dir}/demoProject01 ]; then
    if [ -d ./demoProject01 ]; then
        cp -r ./demoProject01 ${project_data_dir}
    else
        echo "Can not locate the demoProject01 directory, please run myciSetup.sh from the same directory where the demoProject01 directory exists."
        exit 1
    fi
fi



# Run etcdctl to update all key/value pairs, this may trigger automated etcdctl exec-watch script which will call confd to update configuration files; 
bash ~/${outfile1} 1>/dev/null 2>&1

# Sleep for 3 seconds in case another confd from etcdctl exec-watch is updating config files;
# Then Update configuration files using confd if the automated watch script does not run properly;
sleep 3
confd -onetime -backend etcd  -node 127.0.0.1:4001 1>/dev/null 2>&1

# You could also use etcdctl outside this script to set/update the keys and then manually run following command to debug
# confd -onetime -backend etcd --log-level=debug -node 127.0.0.1:4001
