#!/bin/bash
set -e

# Add common variables.
echo ">>>> Import common variables."
source ~/ci/config
source ~/ci/config.default

#Create administrator in Gerrit.
echo ">>>> Setup Gerrit."
source ~/gerrit-docker/addGerritUser.sh

#Integrate Jenkins with Gerrit.
echo ">>>> Setup Jenkins."
source ~/jenkins-docker/setupJenkins.sh

#Restart Nginx proxy.
echo ">>>> Restart Nginx proxy."
docker restart ${NGINX_NAME}

