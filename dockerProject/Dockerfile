FROM tomcat:7-jre7

MAINTAINER zsx <thinkernel@gmail.com>

ARG jenkins_url
ARG build_number

# Remove examples and docs
RUN rm -rf /usr/local/tomcat/webapps/examples /usr/local/tomcat/webapps/docs

RUN curl -L ${jenkins_url}/job/demo/${build_number}/artifact/demo/target/demo-0.0.1-SNAPSHOT.jar \
         -o ${CATALINA_HOME}/webapps/demo-0.0.1-SNAPSHOT.jar
