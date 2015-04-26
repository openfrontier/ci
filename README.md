# ci project
Continuous integration system base on other docker projects.

## Get docker images.
    docker pull openfrontier/gerrit
    docker pull openfrontier/jenkins
    docker pull postgres

## Get scriptes.
    cd ~
    git clone https://github.com/openfrontier/gerrit-docker.git
    git clone https://github.com/openfrontier/jenkins-docker.git
    git clone https://github.com/openfrontier/ci.git

## Create all containers.
    ## Edit variables according to your environment.
    vi ~/ci/commonVar.sh
    ## Create Gerrit Jenkins PostgreSQL containers.
    ~/ci/createContainer.sh <LDAP account search baseDN> <gerrit admin uid> <gerrit admin password> <gerrit admin email>
    ## Integrate Jenkins with Gerrit.
    ~/ci/setupContainer.sh  <LDAP account search baseDN> <gerrit admin uid> <gerrit admin password> <gerrit admin email>

## Destroy all containers.(Use with caution!) 
    ~/ci/destroyContainer.sh
