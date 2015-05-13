# ci project
Continuous integration system base on other docker projects.

Create a Gerrit with PostgreSQL as backend and OpenLDAP as authentication server.

Create a Jenkins that integrate with Gerrit.

Create a Redmine container.

Create a Nginx as a reverse proxy of the Gerrit, Jenkins and Redmine.

Create a data container based on busybox to provide volume for the Gerrit containter

Create a data container based on busybox to provide volume for the Jenkins containter

Create a a sidekick container based on coreos/etcd to store configuration variables and generate the docker-compose.yml file 

## Create your docker-compose.yml and nginx-proxy.conf file 
    ## You can customize your local variables in setEnv.sh, those varibles are set by etcdctl command in that script; 
    ## By default, /etc/confd/output/docker-compose.yml will be generated after run setEnv.sh script; 
    ## A /etc/confd/output/nginx-proxy.conf will also be gernerated by setEnv.sh script;
    ## You may change the output location in ci-docker-compose.toml and ci-nginx-proxy-conf.toml config file.

    sh ~/ci/setEnv.sh
    
    ## If you don't want to use this setEnv.sh script,  you can simply use the 
    ## docker-compose.yml.example and nginx-proxy.conf.example as a template, and change 
    ## the parameters in it based on your environment;
    ## Following parameters are most likely need be changed in your docker-compose.yml and nginx-proxy.conf:
   
    WEBURL              # Change the IP address to your docker host ip in your docker-compose.yml;
    LDAP_SERVER         # Change the IP address to your LDAP server ip in your docker-compose.yml;
    LDAP_ACCOUNTBASE    # Change the search base to your LDAP account base in your docker-compose.yml;

    ## See more parameters in the "MOST LIKELY NEED CHANGE" section in the setEnv.sh for details; 

    server_name         # Change the IP address to your docker host ip or hostname in your nginx-proxy.conf;

## Use docker-compose to start,stop or control the containers in this project
    ## cd to the directory where the docker-compose.yml is generated; 
    ## by default it is in /etc/confd/output, you may copy it to anywhere you want and cd to that directory;
    ## or you can use the "docker-compose -f <file> <docker_command_options>" to specify its location;
    ## then run following command to bring up all containers:

    docker-compose up    # or: "docker-compose -f /etc/confd/output/docker-compose.yml up"

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

## After containers are up and running and you can login using your gerrit admin user, run following postinstall scripts
   ## To setup the intial login in Gerrit and link jenkins with gerrit:
   sh etc/confd/output/postinstall/S01setupContainer.sh

   ## TODO: import a demo project

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
