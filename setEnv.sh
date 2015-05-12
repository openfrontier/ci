#!/bin/bash
#Set environment variables used by confd

export DATAGERRIT_IMAGE=datagerrit
export datagerrit_name=datagerrit
export datajenkins_image=datajenkins
export datajenkins_name=datajenkins
export pggerrit_name=pg-gerrit
export pggerrit_postgres_user=gerrit2
export pggerrit_postgres_password=gerrit
export pggerrit_postgres_db=reviewdb
export gerrit_image=openfrontier/gerrit
export gerrit_name=gerrit
export gerrit_weburl=http://192.168.1.141/gerrit
export gerrit_httpd_listenurl=proxy-http://*:8080/gerrit
export gerrit_database_type=postgresql
export gerrit_auth_type=LDAP
export gerrit_ldap_server=192.168.1.250
export gerrit_ldap_accountbase="cn=users,cn=accounts,dc=pod0,dc=nethsd,dc=net"
export jenkins_image=openfrontier/jenkins
export jenkins_name=jenkins
export jenkins_opts="--prefix=/jenkins"
export pgredmine_image=postgres
export pgredmine_name=pg-redmine
export pgredmine_postgres_user=redmine
export pgredmine_postgres_password=redmine
export pgredmine_postgres_db=redmine
export redmine_image=sameersbn/redmine
export redmine_name=redmine
export redmine_db_name=redmine
export redmine_db_user=redmine
export redmine_db_pass=redmine
export redmine_redmin_relative_url_root=/redmine
export redmine_redmin_fetch_commits=hourly
export nginxproxy_image=nginx
export nginxproxy_name=nginx-proxy
export nginxproxy_volumes=~/nginx-docker/proxy.conf:/etc/nginx/conf.d/proxy.conf:ro

confd -onetime -backend env 
