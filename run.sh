#!/bin/bash
set -e

mkdir -p ~/.ssh/
if [ ! -e ~/.ssh/id_rsa -o ! -e ~/.ssh/id_rsa.pub ]; then
  echo "Generating SSH keys..."
  rm -rf ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
  ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -C ${GERRIT_ADMIN_EMAIL}
fi

~/ci/createContainer.sh ${SUFFIX}
while [ -z "$(docker logs gerrit${SUFFIX} 2>&1 | grep "Gerrit Code Review [0-9..]* ready")" ]; do
    echo "Waiting gerrit ready."
    sleep 5
done
while [ -z "$(docker logs jenkins${SUFFIX} 2>&1 | tail -n 20 | grep "Jenkins is fully up and running")" ]; do
    echo "Waiting jenkins ready."
    sleep 5
done
sleep 5
~/ci/setupContainer.sh ${SUFFIX}
sleep 10
while [ -z "$(docker logs jenkins${SUFFIX} 2>&1 | tail -n 20 | grep "Jenkins is fully up and running")" ]; do
    echo "Waiting jenkins ready."
    sleep 5
done
sleep 5
~/ci/importDemoProject.sh ${SUFFIX}
