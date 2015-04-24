#!/bin/bash

# Define common variables.

## Suffix of containers' name
SUFFIX=01

## Gerrit administrator's uid in LDAP
GERRIT_ADMIN_UID=$1
GERRIT_ADMIN_PWD=$2
GERRIT_ADMIN_EMAIL=$3
GERRIT_ADMIN_SSH_KEY_DIR=~/.ssh/id_rsa.pub

## LDAP account baseDN
LDAP_ACCOUNTBASE=ou=accounts,dc=vdc,dc=trans-cosmos,dc=com,dc=cn

## Gerrit access hostname
GERRIT_WEBURL=http://172.20.201.104:8080
GERRIT_SSH_HOST=172.20.201.104

## LDAP Server
LDAP_SERVER=172.20.201.98

## Gerrit server and database containers' name
GERRIT_NAME=gerrit${SUFFIX}
PG_GERRIT_NAME=pg-gerrit${SUFFIX}

## Gerrit docker image name
GERRIT_IMAGE_NAME=openfrontier/gerrit

## Jenkins container's name
JENKINS_NAME=jenkins-master${SUFFIX}

## Jenkins docker image name
JENKINS_IMAGE_NAME=openfrontier/jenkins

