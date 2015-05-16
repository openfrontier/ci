# ci project
Continuous integration system base on other docker projects.

Create a Gerrit with PostgreSQL as backend and OpenLDAP as authentication server.

Create a Jenkins that integrate with Gerrit.

Create a Redmine container.

Create a Nginx as a reverse proxy of the Gerrit, Jenkins and Redmine.

Create a data container based on busybox to provide volume for the Gerrit containter

Create a data container based on busybox to provide volume for the Jenkins containter

Create a a sidekick container based on coreos/etcd to store configuration variables and generate the docker-compose.yml file 

## Create your docker-compose.yml, nginx-proxy.conf and postinstall scripts and bring up all containers 
    ## All configuration files will be generated by etcd and confd
    ## docker-compose.yml.example and nginx-proxy.conf.example are example files for your reference;
    ## First update configuration parameters in ~/ci/myci.conf according to your needs:

    vi  ~/ci/myci.conf

    ## Then run the setup script to generate configuration files
    ## By default,all configuration files will be generated in ~/ci/config directory;
    ## This script will prompt you if you want to start all containers up and import a demo project;
    ## If you choose no, you can run the docker-compose and/or postinstall scripts later;

    ./myciSetup.sh

    ## By default, you can use user/password: gerrit/gerrit123 to login to Gerrit, this assumes such user/password exists in your LDAP  
    ## Please choose your own LDAP user/password and update your myci.conf before setup these containers

    ## After above initial setup, if you want to change configuration parameters, you can run ./updateConf.sh;
    ## Then you can check if the configuration files are updated correctly and use docker-compose to restart some specific or all containers;
 
    ./updateConf.sh
 
    ## For more information about etcd and confd, please check their document,following tutorial is a good start
    https://www.digitalocean.com/community/tutorials/how-to-use-confd-and-etcd-to-dynamically-reconfigure-services-in-coreos

## You can also run setup steps individually using following instructions

## Use docker-compose to start,stop and control the containers in this project
    ## run myciSetup.sh or updateConf.sh just to gernerate configuration files; 
    ## by default they are in ~/ci/config, you may copy it to anywhere you want and cd to that directory;
    ## or you can use the "docker-compose -f <file> <docker_command_options>" to specify its location;
    ## then run following command to bring up all containers:

    docker-compose up    # or for example: "docker-compose -f ~/ci/config/docker-compose.yml up"

    ## If you want to run the containers in detached mode, add a -d switch:
    docker-compose up -d

    ## To check logs:
    docker-compose logs  
    # or:  docker-compose logs <container_name>  (for example, you can view one container's log  by "docker-compose logs gerrit" 

    ## To check conainters status:
    docker-compose ps

    ## To stop the containers:
    docker-compose stop

    ## To destroy/remove the containers:
    docker-compose rm

    ## You can refer to "docker-compose -h" for more options

## Following are postinstall scripts
    ## To setup the intial login in Gerrit and link jenkins with gerrit:
    bash ~/ci/config/postinstall/S00setupContainer.sh

    ## To import a demo project:
    bash ~/ci/config/postinstall/S01importDemoProject.sh

