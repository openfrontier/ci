#!/bin/bash
set -e

# Add common variables.
source ~/ci/config
source ~/ci/config.default

# Create demo project on Gerrit.
curl -X PUT --user ${GERRIT_ADMIN_UID}:${GERRIT_ADMIN_PWD} -d@- --header "Content-Type: application/json;charset=UTF-8" ${GERRIT_WEBURL}/a/projects/demo < ~/ci/demoProject.json

# Setup local git.
rm -rf ~/ci/demo
mkdir ~/ci/demo
git init ~/ci/demo
cd ~/ci/demo

#start ssh agent and add ssh key
eval $(ssh-agent)
ssh-add "${SSH_KEY_PATH}"

git config core.filemode false
git config user.name  ${GERRIT_ADMIN_UID}
git config user.email ${GERRIT_ADMIN_EMAIL}
git config push.default simple
git remote add origin ssh://${GERRIT_ADMIN_UID}@${GERRIT_SSH_HOST}:29418/demo
git fetch -q origin
git fetch -q origin refs/meta/config:refs/remotes/origin/meta/config

# Setup project access right.
## Registered users can change everything since it's just a demo project.
git checkout meta/config
cp ~/ci/groups .
git config -f project.config --add access.refs/*.owner "group Registered Users"
git config -f project.config --add access.refs/*.read "group Registered Users"
git add groups project.config
git commit -m "Add access right to Registered Users."
git push origin meta/config:meta/config

# Import demoProject
git checkout master
tar xf ~/ci/demoProject.tar
git add demo
git commit -m "Init project"
git push origin

#stop ssh agent
kill ${SSH_AGENT_PID}

# Remove local git repository.
cd -
rm -rf ~/ci/demo

curl -X POST -d@- --header "Content-Type: application/xml;charset=UTF-8" ${JENKINS_WEBURL}/createItem?name=demo < ~/ci/jenkins.config.xml

# Import redmine demo data
REDMINE_DEMO_DATA_SQL=redmine-init-demo.sql
docker exec pg-redmine gosu postgres psql -d redmine -U redmine -f /${REDMINE_DEMO_DATA_SQL}
