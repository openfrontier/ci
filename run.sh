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
while [ -z "$(docker logs ${NGINX_NAME} 2>&1 | grep "gerrit ready")" ]; do
    echo "Waiting gerrit ready."
    sleep 1
done
echo "Gerrit is ready"

while [ -z "$(docker logs ${NGINX_NAME} 2>&1 | grep "jenkins ready")" ]; do
    echo "Waiting jenkins ready."
    sleep 1
done
echo "Jenkins is ready"

while [ -z "$(docker logs ${REDMINE_NAME} 2>&1 | grep "INFO success: nginx entered RUNNING state")" ]; do
    echo "Waiting redmine ready."
    sleep 1
done
echo "Redmine is ready"

while [ -z "$(docker logs ${NGINX_NAME} 2>&1 | grep "nexus ready")" ]; do
    echo "Waiting nexus ready."
    sleep 1
done
echo "Nexus is ready"

#sleep 5
~/ci/setupContainer.sh ${SUFFIX}
#sleep 10
echo ">>>> Start import demo projects"
~/ci/importDemoProject.sh ${SUFFIX}
~/ci/importDockerProject.sh ${SUFFIX}

echo ">>>> Everything is ready."
