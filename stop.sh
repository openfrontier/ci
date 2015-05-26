#!/bin/bash
SUFFIX=$1
# Add common variables.
source ~/ci/config
source ~/ci/config.default

# Stop Jenkins server container.
docker stop ${JENKINS_NAME}

# Stop Redmine server container.
docker stop ${REDMINE_NAME}
docker stop ${PG_REDMINE_NAME}

# Stop Gerrit server container.
docker stop ${GERRIT_NAME}
docker stop ${PG_GERRIT_NAME}

# Destroy Nginx proxy server container.
docker stop ${NGINX_NAME}

