#!/bin/bash

# Define common variables.

## Suffix of containers' name
SUFFIX=${SUFFIX:-$5}

## Host IP or DNS name.
HOST_NAME=172.20.201.104

## Gerrit administrator's uid in LDAP
GERRIT_ADMIN_UID=${GERRIT_ADMIN_UID:-$2}
GERRIT_ADMIN_PWD=${GERRIT_ADMIN_PWD:-$3}
GERRIT_ADMIN_EMAIL=${GERRIT_ADMIN_EMAIL:-$4}
GERRIT_ADMIN_SSH_KEY_DIR=~/.ssh/id_rsa.pub

## LDAP Server
LDAP_SERVER=172.20.201.98
## LDAP account baseDN
LDAP_ACCOUNTBASE=${LDAP_ACCOUNTBASE:-$1}

## Gerrit server and database containers' name
GERRIT_NAME=gerrit${SUFFIX}
PG_GERRIT_NAME=pg-gerrit${SUFFIX}

## Gerrit access hostname
GERRIT_WEBURL=http://${HOST_NAME}/${GERRIT_NAME}
HTTPD_LISTENURL=proxy-http://*:8080/${GERRIT_NAME}
GERRIT_SSH_HOST=${HOST_NAME}

## Gerrit docker image's name
GERRIT_IMAGE_NAME=openfrontier/gerrit

## Jenkins container's name
JENKINS_NAME=jenkins${SUFFIX}

## Jenkins start options
JENKINS_OPTS=--prefix=/${JENKINS_NAME}

## Jenkins docker image's name
JENKINS_IMAGE_NAME=openfrontier/jenkins

## Jenkins access
JENKINS_WEBURL=http://${HOST_NAME}/${JENKINS_NAME}

## Redmine container's name
REDMINE_NAME=redmine${SUFFIX}
PG_REDMINE_NAME=pg-redmine${SUFFIX}

## Redmine docker image's name
REDMINE_IMAGE_NAME=sameersbn/redmine

## Nginx docker container's name
NGINX_NAME=proxy

## Nginx docker images's name
NGINX_IMAGE_NAME=nginx

