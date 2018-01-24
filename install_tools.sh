#!/bin/sh

base() {
    yum -y install coreutils
    yum -y install net-tools
}

#install shadowssocks
shadowsocks() {
    yum -y install python-setuptools && easy_install pip
    pip install shadowsocks
    cp ./conf/shadowsocks.json /etc/
    ssserver -c /etc/shadowsocks.json -d start
}

#better top command
htop() {
    yum -y install epel-release
    yum -y update
    yum -y install htop
}

nginx() {
    sudo yum -y install epel-release
    sudo yum -y install nginx

    sudo systemctl start nginx

    sudo firewall-cmd --permanent --zone=public --add-service=http 
    sudo firewall-cmd --permanent --zone=public --add-service=https
    sudo firewall-cmd --reload
}
