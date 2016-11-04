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

#sleep 5
~/ci/setupContainer.sh
#sleep 5
~/ci/importDemoProject.sh
~/ci/importDockerProject.sh

echo ">>>> Everything is ready."
