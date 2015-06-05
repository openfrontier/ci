#!/bin/bash
set -e

source ~/ci/config
source ~/ci/config.default

if [ ! -e "${SSH_KEY_PATH}" -o ! -e "${SSH_KEY_PATH}.pub" ]; then
  echo "Generating SSH keys..."
  rm -rf "${SSH_KEY_PATH}" "${SSH_KEY_PATH}.pub"
  mkdir -p "${SSH_KEY_PATH%/*}"
  ssh-keygen -t rsa -N "" -f "${SSH_KEY_PATH}" -C ${GERRIT_ADMIN_EMAIL}
fi

~/ci/createContainer.sh ${SUFFIX}
while [ -z "$(docker logs ${GERRIT_NAME} 2>&1 | grep "Gerrit Code Review [0-9..]* ready")" ]; do
    echo "Waiting gerrit ready."
    sleep 1
done
while [ -z "$(docker logs ${JENKINS_NAME} 2>&1 | grep "Jenkins is fully up and running")" ]; do
    echo "Waiting jenkins ready."
    sleep 1
done
#sleep 5
~/ci/setupContainer.sh ${SUFFIX}
#sleep 10
while [ -n "$(docker logs ${JENKINS_NAME} 2>&1 | tail -n 5 | grep 'Running from: /usr/share/jenkins/jenkins.war')" -o \
        -z "$(docker logs ${JENKINS_NAME} 2>&1 | tail -n 5 | grep 'Jenkins is fully up and running')" ]; do
    echo "Waiting jenkins ready."
    sleep 1
done
#sleep 5
~/ci/importDemoProject.sh ${SUFFIX}

echo ">>>> Everything is ready."
