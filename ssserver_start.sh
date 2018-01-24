#!/bin/sh

PROCESS_NUM=$(ps -ef | grep "/usr/bin/ssserver" | grep -v "grep" | wc -l)

if [ ${PROCESS_NUM} -eq 0 ]; then
	/usr/bin/ssserver -c /etc/shadowsocks.json -d start
fi
