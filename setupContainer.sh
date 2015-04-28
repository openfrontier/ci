#!/bin/bash
set -e

# Add common variables.
echo ">>>> Importing common variables."
source ~/ci/commonVar.sh

#Create administrator in Gerrit.
echo ">>>> Setting up Gerrit."
source ~/gerrit-docker/addGerritUser.sh

#Integrate Jenkins with Gerrit.
echo ">>>> Setting up Jenkins."
source ~/jenkins-docker/setupJenkins.sh

#Restart Nginx proxy.
docker restart ${NGINX_NAME}

