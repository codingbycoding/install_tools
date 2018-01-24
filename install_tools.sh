#!/bin/sh

declare -a PACKAGES=(base) 


POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p|--pkg)
    INPUT_PACKAGES=()
    INPUT_PACKAGES+=("$2")
    shift # past argument
    while [[ -n $2 ]] && ! [[ $2 == "-"* ]]
    do
    INPUT_PACKAGES+=("$2")
    shift # past value

    done
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done


base() {
    sudo yum -y install coreutils
    sudo yum -y install net-tools
}

#install shadowssocks
shadowsocks() {
    sudo yum -y install python-setuptools  
    sudo easy_install pip


    sudo pip install shadowsocks
    sudo cp ./conf/shadowsocks.json /etc/
    sudo ssserver -c /etc/shadowsocks.json -d start

    sudo firewall-cmd --add-port=10000/tcp
    sudo firewall-cmd --permanent --add-port=10000/tcp

    sudo firewall-cmd --add-port=10001/tcp
    sudo firewall-cmd --permanent --add-port=10001/tcp

    sudo firewall-cmd --add-port=10002/tcp
    sudo firewall-cmd --permanent --add-port=10002/tcp
}

#better top command
htop() {
    sudo yum -y install epel-release
    sudo yum -y update
    sudo yum -y install htop
}

nginx() {
    sudo yum -y install epel-release
    sudo yum -y install nginx

    sudo systemctl start nginx
    sudo systemctl enable nginx

    sudo firewall-cmd --permanent --zone=public --add-service=http 
    sudo firewall-cmd --permanent --zone=public --add-service=https
    sudo firewall-cmd --reload

}

INSTALL_PACKAGES=${PACKAGES[@]}
if ! [ -z ${INPUT_PACKAGES+x} ]; then
    INSTALL_PACKAGES=${INPUT_PACKAGES[@]}
fi

echo "INSTALL_PACKAGES:${INSTALL_PACKAGES[@]}"

for each_pkg in ${INSTALL_PACKAGES[@]}
do
    $each_pkg
done
