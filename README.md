# ci project
Continuous integration system base on other docker projects.

Create a Gerrit with PostgreSQL as backend and OpenLDAP as authentication server.

Create a Jenkins that integrate with Gerrit.

Create a Redmine container.

Create a Nginx as a reverse proxy of the Gerrit, Jenkins and Redmine.

Create a data container based on busybox to provide volume for the Gerrit containter

Create a data container based on busybox to provide volume for the Jenkins containter

Create a coreos/etcd as a sidekick container to store configuration variables 

## Create docker-compose.yml file 
    ## You can customize your variables in the setEnv.sh, then run setEnv.sh, it will generate a docker-compose.yml file similar to the docker-compose.yml.example 
    ~/ci/setEnv.sh
    
    ## Or you can use the docker-compose.yml.example as a template, and change the parameters in it based on your environment,
    ## Following parameters are most likely need be changed:
    WEBURL              # Change the IP address to your docker host ip;
    LDAP_SERVER         # Change the IP address to your LDAP server ip;
    LDAP_ACCOUNTBASE    # Change the base to your LDAP account base, this example is based on a freeipa LDAP server with domain "example.com";

## Use docker-compose to start,stop or monitor the containers in this project
    ## cd to the directory where the docker-compose.yml is generated, run following commands:
    docker-compose up

    ## If you want to run the containers in detached mode, add a -d switch:
    docker-compose up -d

    ## To check logs:
    docker-compose logs  
    or:  docker-compose logs <container_name>  (for example, container_name gerrit,  you can find its logs by `docker-compose logs gerrit` 

    ## To check conainters status:
    docker-compose ps

    ## To stop the containers:
    docker-compose stop

    ## To destroy/remove the containers:
    docker-compose rm

## Following are instructions if you do not want to use docker-compose

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
    vi ~/ci/commonVar.sh
    ## Create Gerrit Jenkins Redmine PostgreSQL containers.
    ~/ci/createContainer.sh <LDAP account search baseDN> <gerrit admin uid> <gerrit admin password> <gerrit admin email>
    ## Integrate Jenkins with Gerrit.
    ~/ci/setupContainer.sh  <LDAP account search baseDN> <gerrit admin uid> <gerrit admin password> <gerrit admin email>
    ## Import demo project to Gerrit and Jenkins.
    ~/ci/importDemoProject.sh  <gerrit admin uid> <gerrit admin password> <gerrit admin email>

## Access those services.
    ## Gerrit
    http://your.server.url/gerrit
    Login by <gerrit admin uid> and <gerrit admin password>
    ## Jenkins
    http://your.server.url/jenkins
    ## Redmine
    http://your.server.url/redmine
    Default Administrator's username and password is admin/admin.

## Destroy all containers.(Use with caution!) 
    ~/ci/destroyContainer.sh
