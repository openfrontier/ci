#!/bin/bash
set -e

# Add common variables.
echo ">>>> Import common variables."
source ~/ci/config
source ~/ci/config.default

#Import local ssh key in Gerrit.
#Change default All-project access right
echo ">>>> Setup Gerrit."
source ~/ci/setupGerrit.sh

#Integrate Redmine with Openldap and import init data.
#echo ">>>> Setup Redmine."
#source ~/redmine-docker/setupRedmine.sh

#Restart Nginx proxy.
#echo ">>>> Restart Nginx proxy."
#docker restart ${NGINX_NAME}
