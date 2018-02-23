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

bbr() {
    sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
    sudo yum --enablerepo=elrepo-kernel install kernel-ml -y
    rpm -qa | grep kernel
    sudo egrep ^menuentry /etc/grub2.cfg | cut -f 2 -d \'
    sudo grub2-set-default 1
    # sudo shutdown -r now
    uname -r

    echo 'net.core.default_qdisc=fq' | sudo tee -a /etc/sysctl.conf
    echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    sudo sysctl net.ipv4.tcp_available_congestion_control
    # net.ipv4.tcp_available_congestion_control = bbr cubic reno

    sudo sysctl -n net.ipv4.tcp_congestion_control
    # output of previous command
    # bbr

    lsmod | grep bbr
    # output of previous command
    # tcp_bbr                16384  0
}


certbot() {
    sudo yum -y install yum-utils
    sudo yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
    sudo yum -y install certbot-nginx

    sudo certbot renew --dry-run
    # renew in 90 days
    #certbot renew
}

request_ssl_through_certbot() {
    ./certbot-auto --nginx --register-unsafely-without-email
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
