#!/bin/sh

#  install_mysql_57.sh
#
#
#  Created by HSP SI Viet Nam on 6/4/14.
#
#check mysql old
clear
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
check_mysql=`rpm -qa | grep mysql`
if [ "$check_mysql" != "" ]; then
echo "Remove package MySQL Old"
echo $check_mysql
sleep 5
yum -y remove $check_mysql >> ~/log_remove
fi

#check wget install
check_wget=`rpm -qa | grep wget`
if [ "$check_wget" = "" ]; then
echo "Install wget"
sleep 5
yum -y install wget >> ~/log_Install
fi


#install MySQL New Version 5.7
mkdir package_mysql
cd package_mysql
wget https://raw.githubusercontent.com/vietshell/Linux_Script/master/mysql%205.7/MySQL-client-5.7.4_m14-1.el6.x86_64.rpm
wget https://raw.githubusercontent.com/vietshell/Linux_Script/master/mysql%205.7/MySQL-server-5.7.4_m14-1.el6.x86_64.rpm
wget https://raw.githubusercontent.com/vietshell/Linux_Script/master/mysql%205.7/MySQL-shared-5.7.4_m14-1.el6.x86_64.rpm
wget https://raw.githubusercontent.com/vietshell/Linux_Script/master/mysql%205.7/galera-25.3.5-1.rhel6.x86_64.rpm
packg=`ls`
yum -y install $packg >> ~/log_Install
clear
echo "Install MySQL Success Full"
cd ..
rm -rf package_mysql

clear
echo "Install Success"
echo "Start Service"
/etc/init.d/mysql restart
echo "Setting MySQL"
pass_mysql_default=`grep ^[^#] /root/.mysql_secret`
echo "password defaul $pass_mysql_default"
echo "Please login mysql and change password root"
echo "Can you Set password root:"
echo "SET PASSWORD=PASSWORD('HSPvps2013@')"
echo "Thanks!"

