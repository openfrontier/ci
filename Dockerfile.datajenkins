# Data container based on busybox
FROM busybox:latest
MAINTAINER kfmaster <fuhaiou@hotmail.com>
RUN mkdir -p /var/jenkins_home && chown 1000:1000 /var/jenkins_home
VOLUME ["/var/jenkins_home"]
