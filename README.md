# ci project
Continuous integration system base on other docker projects.

Create a Gerrit with PostgreSQL as backend and OpenLDAP as authentication server.

Create a Jenkins that integrate with Gerrit.

Create a Redmine container.

Create a Nginx as a reverse proxy of the Gerrit, Jenkins and Redmine.

## Prerequisites
    A OpenLDAP or AD server with anonymous binding configuration.
    An user account with email in the OpenLDAP or AD server.
    Docker service installed on host.
    Git installed on host.
    A Sonatype Nexus server (Optional).

## Get docker images.
    docker pull openfrontier/gerrit
    docker pull openfrontier/jenkins
    docker pull sameersbn/redmine
    docker pull postgres
    docker pull nginx

## Get scriptes.
    cd ~
    git clone https://github.com/openfrontier/gerrit-docker.git
    git clone https://github.com/openfrontier/jenkins-docker.git
    git clone https://github.com/openfrontier/redmine-docker.git
    git clone https://github.com/openfrontier/nginx-docker.git
    git clone https://github.com/openfrontier/ci.git

## Create all containers.
    ## Edit variables according to your environment.
    vi ~/ci/config
    ## Start all containers.
    ~/ci/run.sh

## Access those services.
    ## Gerrit
    http://your.server.url/gerrit
    Login by <gerrit admin uid> and <gerrit admin password>
    ## Jenkins
    http://your.server.url/jenkins
    ## Redmine
    http://your.server.url/redmine
    Default Administrator's username and password is admin/admin.

## Stop and restart all containers.
    ## Stop all
    ~/ci/stop.sh
    ## Restart all
    ~/ci/start.sh

## Destroy all containers.(Use with caution!) 
    ~/ci/destroyContainer.sh
