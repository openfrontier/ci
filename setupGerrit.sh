#!/bin/bash
set -e

HOST_NAME=${HOST_NAME:-$1}
GERRIT_WEBURL=${GERRIT_WEBURL:-$2}
GERRIT_ADMIN_UID=${GERRIT_ADMIN_UID:-$3}
GERRIT_ADMIN_PWD=${GERRIT_ADMIN_PWD:-$4}
GERRIT_ADMIN_EMAIL=${GERRIT_ADMIN_EMAIL:-$5}
SSH_KEY_PATH=${SSH_KEY_PATH:-~/.ssh/id_rsa}
CHECKOUT_DIR=./git


#Remove appended '/' if existed.
GERRIT_WEBURL=${GERRIT_WEBURL%/}

# Add ssh-key
cat "${SSH_KEY_PATH}.pub" | curl --data @- --user "${GERRIT_ADMIN_UID}:${GERRIT_ADMIN_PWD}"  ${GERRIT_WEBURL}/a/accounts/self/sshkeys

#gather server rsa key
##TODO: This is not an elegant way.
[ -f ~/.ssh/known_hosts ] && mv ~/.ssh/known_hosts ~/.ssh/known_hosts.bak
ssh-keyscan -p 29418 -t rsa ${HOST_NAME} > ~/.ssh/known_hosts

#checkout project.config from All-Project.git
[ -d ${CHECKOUT_DIR} ] && mv ${CHECKOUT_DIR}  ${CHECKOUT_DIR}.$$
mkdir ${CHECKOUT_DIR}

git init ${CHECKOUT_DIR}
cd ${CHECKOUT_DIR}

#start ssh agent and add ssh key
eval $(ssh-agent)
ssh-add "${SSH_KEY_PATH}"

#git config
git config user.name  ${GERRIT_ADMIN_UID}
git config user.email ${GERRIT_ADMIN_EMAIL}
git remote add origin ssh://${GERRIT_ADMIN_UID}@${GERRIT_SSH_HOST}:29418/All-Projects
#checkout project.config
git fetch -q origin refs/meta/config:refs/remotes/origin/meta/config
git checkout meta/config

#add label.Verified
git config -f project.config label.Verified.function MaxWithBlock
git config -f project.config --add label.Verified.defaultValue  0
git config -f project.config --add label.Verified.value "-1 Fails"
git config -f project.config --add label.Verified.value "0 No score"
git config -f project.config --add label.Verified.value "+1 Verified"
##commit and push back
git commit -a -m "Added label - Verified"

#Change global access right
##Remove anonymous access right.
git config -f project.config --unset access.refs/*.read "group Anonymous Users"
##add Jenkins access and verify right
git config -f project.config --add access.refs/heads/*.read "group Non-Interactive Users"
git config -f project.config --add access.refs/tags/*.read "group Non-Interactive Users"
git config -f project.config --add access.refs/heads/*.label-Code-Review "-1..+1 group Non-Interactive Users"
git config -f project.config --add access.refs/heads/*.label-Verified "-1..+1 group Non-Interactive Users"
##add project owners' right to add verify flag
git config -f project.config --add access.refs/heads/*.label-Verified "-1..+1 group Project Owners"
##commit and push back
git commit -a -m "Change access right." -m "Add access right for Jenkins. Remove anonymous access right"
git push origin meta/config:meta/config

#stop ssh agent
kill ${SSH_AGENT_PID}

cd -
rm -rf ${CHECKOUT_DIR}
[ -d ${CHECKOUT_DIR}.$$ ] && mv ${CHECKOUT_DIR}.$$  ${CHECKOUT_DIR}

echo "finish gerrit setup"
