#!/bin/bash
# Written by kfmaster <fuhaiou@hotmail.com>
# Initial written date: 2015-05-12
#
# Using etcd set variables used by confd to gernerate the docker-compose.yml file for the ci project
#

# First create naming spaces for etcd variables
etcdctl mkdir /services
etcdctl mkdir /services/datagerrit
etcdctl mkdir /services/datajenkins
etcdctl mkdir /services/pggerrit
etcdctl mkdir /services/gerrit
etcdctl mkdir /services/jenkins
etcdctl mkdir /services/pgredmine
etcdctl mkdir /services/redmine
etcdctl mkdir /services/nginxproxy

# datagerrit service: this is a data conainter serving the gerrit container
etcdctl set /services/datagerrit/image datagerrit
etcdctl set /services/datagerrit/name datagerrit

# datajenkins service: this is a data conainter serving the jenkins container
etcdctl set /services/datajenkins/image datajenkins
etcdctl set /services/datajenkins/name datajenkins

# pggerrit service: this is a postgres container serving the gerrit container
etcdctl set /services/pggerrit/name pg-gerrit
etcdctl set /services/pggerrit/postgres_user gerrit2
etcdctl set /services/pggerrit/postgres_password gerrit
etcdctl set /services/pggerrit/postgres_db reviewdb

# gerrit service: this is a gerrit container, the main Gerrit Code Review application
# please change the weburl, ldap_server and ldap_accountbase according to your environment

etcdctl set /services/gerrit/image openfrontier/gerrit
etcdctl set /services/gerrit/name gerrit
etcdctl set /services/gerrit/weburl http://192.168.1.141/gerrit
etcdctl set /services/gerrit/httpd_listenurl proxy-http://*:8080/gerrit
etcdctl set /services/gerrit/database_type postgresql
etcdctl set /services/gerrit/auth_type LDAP
etcdctl set /services/gerrit/ldap_server 192.168.1.250
etcdctl set /services/gerrit/ldap_accountbase cn=users,cn=accounts,dc=pod0,dc=nethsd,dc=net

# jenkins service: this is a jenkins container, the main Jenkins application
etcdctl set /services/jenkins/image openfrontier/jenkins
etcdctl set /services/jenkins/name jenkins
etcdctl set /services/jenkins/opts /jenkins

# pgredmine service: this is a postgres container, serving the redmine container
etcdctl set /services/pgredmine/image postgres
etcdctl set /services/pgredmine/name pg-redmine
etcdctl set /services/pgredmine/postgres_user redmine
etcdctl set /services/pgredmine/postgres_password redmine
etcdctl set /services/pgredmine/postgres_db redmine

# redmine service:  this is a redmine container, the main Redmine application
etcdctl set /services/redmine/image sameersbn/redmine
etcdctl set /services/redmine/name redmine
etcdctl set /services/redmine/db_name redmine
etcdctl set /services/redmine/db_user redmine
etcdctl set /services/redmine/db_pass redmine
etcdctl set /services/redmine/redmin_relative_url_root /redmine
etcdctl set /services/redmine/redmin_fetch_commits hourly
etcdctl set /services/redmine/image sameersbn/redmine

# nginxproxy service: this is a nginx container, the main nginx reverse proxy application
etcdctl set /services/nginxproxy/image nginx
etcdctl set /services/nginxproxy/name nginx-proxy
etcdctl set /services/nginxproxy/volumes ~/nginx-docker/proxy.conf:/etc/nginx/conf.d/proxy.conf:ro

# confd program will use config files in /etc/confd/{templates,conf.d} to generate the docker-compose.yml file needed by this project
# Please check the files in /etc/confd/templates and /etc/confd/conf.d for more details
confd -onetime -backend etcd -node 127.0.0.1:4001
