#!/bin/bash
set -e

# Add common variables.
source ~/ci/commonVar.sh

# Create Gerrit server container.
source ~/gerrit-docker/createGerrit.sh

# Create Jenkins server container.
source ~/jenkins-docker/createJenkins.sh

# Create Redmine server container.
source ~/redmine-docker/createRedmine.sh

# Create Nginx proxy server container.
source ~/nginx-docker/createNginx.sh

