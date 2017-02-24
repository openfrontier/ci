#!/bin/bash
SUFFIX=$1
# Add common variables.
source ~/ci/config
source ~/ci/config.default

# Destroy Jenkins server container.
source ~/jenkins-docker/destroyJenkins.sh

# Destroy Redmine server container.
source ~/redmine-docker/destroyRedmine.sh

# Destroy Gerrit server container.
source ~/gerrit-docker/destroyGerrit.sh

# Destroy Nginx proxy server container.
source ~/nginx-docker/destroyNginx.sh

# Destroy OpenLDAP ssp server.
source ~/openldap-docker/destroyOpenSSP.sh

# Destroy OpenLDAP server.
source ~/openldap-docker/destroyOpenLDAP.sh

# Destroy Nexus server.
if [ ${#NEXUS_WEBURL} -eq 0 ]; then
    source ~/nexus-docker/destroyNexus.sh
fi

# Destroy docker network.
docker network rm ${CI_NETWORK}
