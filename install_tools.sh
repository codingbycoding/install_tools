#!/bin/sh
yum -y install coreutils
yum -y install net-tools

#install shadowssocks
yum -y install python-setuptools && easy_install pip
pip install shadowsocks
cp ./conf/shadowsocks.json /etc/
ssserver -c /etc/shadowsocks.json -d start
