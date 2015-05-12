# Data container based on busybox
FROM busybox:latest
MAINTAINER kfmaster <fuhaiou@hotmail.com>
RUN mkdir -p /var/gerrit/review_site && chown 1000:1000 /var/gerrit/review_site
VOLUME ["/var/gerrit/review_site"]
