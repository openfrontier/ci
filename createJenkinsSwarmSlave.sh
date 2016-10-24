#/bin/bash
set -e

NEXUS_REPO=${NEXUS_REPO:-$1}
JENKINS_USERNAME=${GERRIT_ADMIN_UID:-$2}
JENKINS_PASSWD=${GERRIT_ADMIN_PWD:-$3}
JENKINS_SLAVE_IMAGE=${JENKINS_SLAVE_IMAGE:-openfrontier/jenkins-swarm-maven-slave}
LABEL=${LABEL:-swarm}
CI_NETWORK=${CI_NETWORK:-ci-network}

docker run \
  -e NEXUS_REPO=${NEXUS_REPO} \
  --net=${CI_NETWORK} \
  --restart=unless-stopped \
  -d ${JENKINS_SLAVE_IMAGE} \
  -labels ${LABEL} \
  -mode exclusive \
  -username ${JENKINS_USERNAME} \
  -password ${JENKINS_PASSWD} \
  -executors 1
