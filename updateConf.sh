#!/bin/bash

OUTFILE=tmp_etcdctl.sh
cd ~
touch ${OUTFILE}
cd - 1>/dev/null

if [ -e ./myci.conf ]; then
    grep -v "^#" ./myci.conf |grep -v "^#" | awk '{print "etcdctl set",$1,$2}' > ~/${OUTFILE}
else
    echo "Can't fine setEnv.conf in current directory, please place it in `pwd`"
fi

bash ~/${OUTFILE} 1>/dev/null 2>&1

confd -onetime -backend etcd -node 127.0.0.1:4001
