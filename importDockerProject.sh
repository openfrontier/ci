#!/bin/bash
set -e

# Add common variables.
source ~/ci/config
source ~/ci/config.default

# Create demo project on Gerrit.
curl -X PUT --user ${GERRIT_ADMIN_UID}:${GERRIT_ADMIN_PWD} -d@- --header "Content-Type: application/json;charset=UTF-8" ${GERRIT_WEBURL}/a/projects/demo-docker < ~/ci/demoProject.json

# Setup local git.
rm -rf ~/ci/demo-docker
mkdir ~/ci/demo-docker
git init ~/ci/demo-docker
cd ~/ci/demo-docker

#start ssh agent and add ssh key
eval $(ssh-agent)
ssh-add "${SSH_KEY_PATH}"

git config core.filemode false
git config user.name  ${GERRIT_ADMIN_UID}
git config user.email ${GERRIT_ADMIN_EMAIL}
git config push.default simple
git remote add origin ssh://${GERRIT_ADMIN_UID}@${GERRIT_SSH_HOST}:29418/demo-docker
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
cp -R ~/ci/dockerProject .
git add dockerProject
git commit -m "Init project"
git push origin

#stop ssh agent
kill ${SSH_AGENT_PID}

# Remove local git repository.
cd -
rm -rf ~/ci/demo-docker

# Create job in Jenkins
sed "s#{{JENKINS_URL}}#${JENKINS_WEBURL}#g" ~/ci/jenkins.demo-docker.config.xml.template > ~/ci/jenkins.demo-docker.config.xml
curl -X POST -d@- --header "Content-Type: application/xml;charset=UTF-8" ${JENKINS_WEBURL}/createItem?name=demo-docker < ~/ci/jenkins.demo-docker.config.xml

# Import redmine demo data
#REDMINE_DEMO_DATA_SQL=redmine-init-demo.sql
#docker exec pg-redmine gosu postgres psql -d redmine -U redmine -f /${REDMINE_DEMO_DATA_SQL}
# Non member add roles
#docker exec pg-redmine gosu postgres psql -d redmine -U redmine -c "update roles set permissions = '---\n- :view_issues\n- :add_issues\n- :view_changesets\n' where id = 1"

# Create jenkins slave docker volume.
#source ~/jenkins-slave-docker/createJenkinsSlave.sh
