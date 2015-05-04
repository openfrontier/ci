#!/bin/bash
set -e

GERRIT_ADMIN_UID=$1
GERRIT_ADMIN_PWD=$2
GERRIT_ADMIN_EMAIL=$3
SUFFIX=$4
GERRIT_WEBURL=http://172.20.201.104/gerrit${SUFFIX}
JENKINS_WEBURL=http://172.20.201.104/jenkins${SUFFIX}
GERRIT_SSH_HOST=172.20.201.104

curl -X PUT --user ${GERRIT_ADMIN_UID}:${GERRIT_ADMIN_PWD} -d@- --header "Content-Type: application/json;charset=UTF-8" ${GERRIT_WEBURL}/a/projects/demo < ~/ci/demoProject.json

mkdir demo
git init demo
cd demo
git config core.filemode false
git config core.autocrlf true
git config user.name  ${GERRIT_ADMIN_UID}
git config user.email ${GERRIT_ADMIN_EMAIL}
git remote add origin ssh://${GERRIT_ADMIN_UID}@${GERRIT_SSH_HOST}:29418/demo
git fetch -q origin
git checkout master
tar xf ~/ci/demoProject.tar
git add demo
git commit -m "Init project"
git push origin
cd -
rm -rf demo

curl -X POST -d@- --header "Content-Type: application/xml;charset=UTF-8" ${JENKINS_WEBURL}/createItem?name=demo < ~/ci/config.xml
