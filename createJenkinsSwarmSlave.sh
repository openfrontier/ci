#/bin/bash
set -e

NEXUS_REPO=${NEXUS_REPO:-$1}
JENKINS_SLAVE_IMAGE=${JENKINS_SLAVE_IMAGE:-openfrontier/jenkins-swarm-maven-slave}
LABEL=${LABEL:-swarm}
CI_NETWORK=${CI_NETWORK:-ci-network}

docker run \
  -e NEXUS_REPO=${NEXUS_REPO} \
  --net=${CI_NETWORK} \
  -d ${JENKINS_SLAVE_IMAGE} \
  -labels ${LABEL} \
  -mode exclusive \
  -executors 1
