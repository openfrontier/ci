#!/bin/bash

OUTFILE=tmp_etcdctl.sh
cd ~
touch ${OUTFILE}
cd - 1>/dev/null

if [ -e ./setEnv.conf ]; then
    grep -v "^#" ./setEnv.conf |grep -v "^#" | awk '{print "etcdctl set",$1,$2}' > ~/${OUTFILE}
else
    echo "Can't fine setEnv.conf in current directory, please place it in `pwd`"
fi

bash ~/${OUTFILE} 1>/dev/null 2>&1

