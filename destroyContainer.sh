#!/bin/bash
set -e

# Add common variables.
source ./commonVar.sh

# Destroy Jenkins server container.
source ~/jenkins-docker/destroyJenkins.sh

# Destroy Gerrit server container.
source ~/gerrit-docker/destroyGerrit.sh

