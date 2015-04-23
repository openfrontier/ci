# ci project
Continuous integration system base other docker projects.

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
    vi ~/ci/commonVar.sh
    ~/ci/createContainer.sh
    ~/ci/setupContainer.sh <gerrit admin uid> <gerrit admin password> <gerrit admin email>

## Destroy all containers.(Use with caution!) 
    ~/ci/destroyContainer.sh
