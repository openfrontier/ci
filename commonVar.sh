#!/bin/bash

# Define common variables.

## Suffix of containers' name
SUFFIX=${SUFFIX:-$5}

## Gerrit administrator's uid in LDAP
GERRIT_ADMIN_UID=${GERRIT_ADMIN_UID:-$2}
GERRIT_ADMIN_PWD=${GERRIT_ADMIN_PWD:-$3}
GERRIT_ADMIN_EMAIL=${GERRIT_ADMIN_EMAIL:-$4}
GERRIT_ADMIN_SSH_KEY_DIR=~/.ssh/id_rsa.pub

## LDAP Server
LDAP_SERVER=172.20.201.98
## LDAP account baseDN
LDAP_ACCOUNTBASE=${LDAP_ACCOUNTBASE:-$1}

## Gerrit access hostname
GERRIT_WEBURL=http://172.20.201.104:8080
GERRIT_SSH_HOST=172.20.201.104

## Gerrit server and database containers' name
GERRIT_NAME=gerrit${SUFFIX}
PG_GERRIT_NAME=pg-gerrit${SUFFIX}

## Gerrit docker image name
GERRIT_IMAGE_NAME=openfrontier/gerrit

## Jenkins container's name
JENKINS_NAME=jenkins-master${SUFFIX}

## Jenkins docker image name
JENKINS_IMAGE_NAME=openfrontier/jenkins

