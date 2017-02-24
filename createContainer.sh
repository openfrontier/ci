#!/bin/bash
set -e

# Add common variables.
source ~/ci/config
source ~/ci/config.default

# Create ci network
if [ -z "$(docker network ls | grep ${CI_NETWORK})" ]; then
  docker network create ${CI_NETWORK}
fi

# Create Nexus server.
if [ ${#NEXUS_WEBURL} -eq 0 ]; then
    source ~/nexus-docker/createNexus.sh
fi

# Create OpenLDAP server.
if [ ${#SLAPD_DOMAIN} -gt 0 -a ${#SLAPD_PASSWORD} -gt 0 ]; then
    source ~/openldap-docker/createOpenLDAP.sh
fi

# Create OpenLDAP ssp server
source ~/openldap-docker/createOpenSSP.sh

# Create Gerrit server container.
source ~/gerrit-docker/createGerrit.sh

# Create Jenkins server container.
source ~/jenkins-docker/createJenkins.sh

# Create Redmine server container.
source ~/redmine-docker/createRedmine.sh

# Create Nginx proxy server container.
source ~/nginx-docker/createNginx.sh

