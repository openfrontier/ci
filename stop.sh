#!/bin/bash
SUFFIX=$1
# Add common variables.
source ~/ci/config
source ~/ci/config.default

# Stop Jenkins server container.
docker stop ${JENKINS_NAME}

# Stop Nexus server container.
if [ -n "$(docker ps | grep ${NEXUS_NAME})" ]; then
    docker stop ${NEXUS_NAME}
fi

# Stop Redmine server container.
docker stop ${REDMINE_NAME}
docker stop ${PG_REDMINE_NAME}

# Stop Gerrit server container.
docker stop ${GERRIT_NAME}
docker stop ${PG_GERRIT_NAME}

# Stop Nginx proxy server container.
docker stop ${NGINX_NAME}

#Stop OpenLDAP server container.
if [ -n "$(docker ps | grep ${LDAP_NAME})" ]; then
    docker stop ${LDAP_NAME}
fi
