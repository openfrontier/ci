#!/bin/bash
SUFFIX=$1
# Add common variables.
source ~/ci/commonVar.sh

# Destroy Jenkins server container.
source ~/jenkins-docker/destroyJenkins.sh

# Destroy Gerrit server container.
source ~/gerrit-docker/destroyGerrit.sh

# Destroy Nginx proxy server container.
source ~/nginx-docker/destroyNginx.sh

