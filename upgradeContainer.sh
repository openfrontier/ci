#!/bin/bash
set -e

# Add common variables.
source ~/ci/config
source ~/ci/config.default

# Create OpenLDAP server.
#if [ ${#SLAPD_DOMAIN} -gt 0 -a ${#SLAPD_PASSWORD} -gt 0 ]; then
#    source ~/openldap-docker/upgradeOpenLDAP.sh
#fi

# Upgrade Gerrit server container.
source ~/gerrit-docker/upgradeGerrit.sh

while [ -z "$(docker logs ${GERRIT_NAME} 2>&1 | tail -n 4 | grep "Gerrit Code Review [0-9..]* ready")" ]; do
    echo "Waiting gerrit ready."
    sleep 1
done

# Upgrade Jenkins server container.
source ~/jenkins-docker/upgradeJenkins.sh

while [ -z "$(docker logs ${JENKINS_NAME} 2>&1 | tail -n 5 | grep "setting agent port for jnlp")" ]; do
    echo "Waiting jenkins ready."
    sleep 1
done

# Upgrade Redmine server container.
#source ~/redmine-docker/upgradeRedmine.sh
#
#while [ -z "$(docker logs ${REDMINE_NAME} 2>&1 | tail -n 5 | grep 'INFO success: nginx entered RUNNING state')" ]; do
#    echo "Waiting redmine ready."
#    sleep 1
#done
#
# Upgrade Nginx proxy server container.
source ~/nginx-docker/upgradeNginx.sh
