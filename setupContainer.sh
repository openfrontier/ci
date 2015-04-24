#!/bin/bash
set -e

# Add common variables.
source ~/ci/commonVar.sh "$1" "$2" "$3"

#Create administrator in Gerrit.
source ~/gerrit-docker/addGerritUser.sh

#Integrate Jenkins with Gerrit.
source ~/jenkins-docker/setupJenkins.sh

