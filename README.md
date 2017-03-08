# ci project
## Features
* Continuous integration system base on other docker projects.
* Create a Gerrit with PostgreSQL as backend and OpenLDAP as authentication server.
* Create a Jenkins that integrate with Gerrit.
* Create a Jenkins slave workspace volume.
* Create a Redmine with OpenLDAP as authentication server.
* Optionally create a OpenLDAP container for demo.
* Optionally create a Nexus as local maven repository.
* Create a Nginx as a reverse proxy of the Gerrit, Jenkins, Redmine, Nexus(Optional).
* Import a project to demonstrate the configuration of Gerrit, Jenkins, Redmine which including:
  * Using Jenkins gerrit plugin to trigger builds from gerrit.
  * Using Jenkins swarm plugin to trigger builds on a dockerized slave node.

## Prerequisites
    Docker service installed on host.
    Git installed on host.
    A OpenLDAP or AD server with anonymous binding configuration. (Optional)
    An user account with email in the OpenLDAP or AD server. (Optional)
    A Sonatype Nexus server. (Optional)

## Get docker images.
    docker pull openfrontier/gerrit-ci
    docker pull openfrontier/jenkins
    docker pull openfrontier/jenkins-swarm-maven-slave
    docker pull sameersbn/redmine
    docker pull postgres
    docker pull openfrontier/nginx
    docker pull openfrontier/openldap (Optional)
    docker pull openfrontier/nexus (Optional)

## Get scripts.
    cd ~
    git clone https://github.com/openfrontier/gerrit-docker.git
    git clone https://github.com/openfrontier/jenkins-docker.git
    git clone https://github.com/openfrontier/redmine-docker.git
    git clone https://github.com/openfrontier/nginx-docker.git
    git clone https://github.com/openfrontier/ci.git

    # These two are optional
    git clone https://github.com/openfrontier/openldap-docker.git
    git clone https://github.com/openfrontier/nexus-docker.git

## Create all containers.
    ## Edit variables according to your environment.
    vi ~/ci/config
    ## Start all containers.
    ~/ci/run.sh

## Access those services.
    ## Homepage
    http://your.server.url
    ## Gerrit
    http://your.server.url/gerrit
    Login by <gerrit admin uid> and <gerrit admin password>
    ## Jenkins
    http://your.server.url/jenkins
    ## Redmine
    http://your.server.url/redmine
    Default Administrator's username and password is admin/admin.
    ## Nexus (Optional)
    http://your.server.url/nexus
    Default Administrator's username and password is admin/admin123.

## Stop and restart all containers.
    ## Stop all
    ~/ci/stop.sh
    ## Restart all
    ~/ci/start.sh

## Upgrade containers.(Use with caution!)
    ## Upgrade Gerrit, Jenkins, Redmine, Nginx
    ## Keep all data containers untouched.
    ## Gerrit 2.10.6 -> 2.11.2 has been tested.
    ~/ci/upgradeContainer.sh

## Destroy all containers.(Use with caution!) 
    ~/ci/destroyContainer.sh
