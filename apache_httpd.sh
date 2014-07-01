#!/bin/sh

#  apache_httpd.sh
#  
#
#  Created by HSP SI Viet Nam on 6/27/14.
#
if [ $(id -u) != "0" ]; then
printf "Error: Ban khong phai la supper admin!\n"
printf "Vui long dang nhap bang tai khoan supper admin de co the tien hanh cai dat!\n"
sleep 3
exit
fi
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
my_ip=`ifconfig $(route -n | grep UG | awk '{print $8}') | grep 'inet addr:' | awk '{print $2}' | sed 's/addr://g'`
my_link=`echo $0`

#check mysql old
check_mysql=`rpm -qa | grep mysql`
if [ "$check_mysql" != '' ]; then
yum -y remove $check_mysql >> ~/log_remove
fi

#check httpd old
echo "Install apache"
echo "Please Wait....."
httpd_old=`rpm -qa | grep httpd`
if [ "$httpd_old" != '' ]; then
yum -y remove $httpd_old >> ~/log_remove
fi
yum -y install httpd httpd-devel >> ~/log_Install

#check php old
check_php=`rpm -qa | grep php`
if [ "$check_php" != '' ]; then
yum -y remove $check_php >> ~/log_remove
fi
echo "Install php"
echo "Please Wait....."
yum -y install php php-* >> ~/log_Install

#check wget install
check_wget=`rpm -qa | grep wget`
if [ "$check_wget" = '' ]; then
echo "Install wget"
echo "Please Wait....."
yum -y install wget >> ~/log_Install
fi

#check epel release 6.8
check_epel=`rpm -qa | grep epel`
if [ "$check_epel" = '' ]; then
echo "Install epel"
echo "Please Wait....."
yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm >> ~/log_Install
fi

check_ntp=`rpm -qa | grep ntp`
if [ "$check_ntp" = "" ]; then
echo "Install ntp"
echo "Please Wait....."
yum -y install ntp >> ~/log_Install
fi

#install module php
#yum -y install php-* --skip-broken php-pecl-zendopcache php-xcache php-pecl-http php-pecl-apc php-pecl-apcu php-xcache php-pecl-zendopcache php-pecl-http1-devel php-xcache php-ZendFramework2-common php-pecl-apcu-devel php-pecl-gmagick php-pecl-http1 >> >> ~/log_Install

#change timezone VN
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
ntpdate pool.ntp.org
clear
echo "Install package success"
echo "Setting apache"
sleep 3
mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.bk
sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/httpd/conf/httpd.conf
sed -i 's/KeepAlive Off/KeepAlive On/g' /etc/httpd/conf/httpd.conf
sed -i 's/\#ServerName www.example.com:80/ServerName $my_ip:80/g' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
sed -i 's/Options Indexes FollowSymLinks/Options -Indexes FollowSymLinks/g' /etc/httpd/conf/httpd.conf
sed -i 's/DirectoryIndex index.html index.html.var/DirectoryIndex index.html index.php index.cgi/g' /etc/httpd/conf/httpd.conf
sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/httpd/conf/httpd.conf
sed -i 's/\#NameVirtualHost \*:80/NameVirtualHost \*:80/g' /etc/httpd/conf/httpd.conf

cat > /etc/httpd/conf.d/1.conf << eof
<VirtualHost *:80>
    ServerAdmin root@$my_ip
    DocumentRoot /var/www/html
    ServerName $my_ip
    ErrorLog logs/$my_ip-error_log
    CustomLog logs/$my_ip-access_log common
</VirtualHost>
eof

iptables -F
service iptables save
chkconfig httpd on
chkconfig iptables on

#vhost
#create file vhost
cat > /usr/bin/vhost << eof
#!/bin/sh

#  vhost.sh
#
#
#  Created by HSP SI Viet Nam on 5/22/14.
#
clear
tf=\`echo $0\`
if [ \$(id -u) != "0" ]; then
echo "Ban Khong Phai La Supper User."
echo "Ban Khong Co Quyen Tao VHost"
echo "Vui long dang nhap vao tai khoan Supper User."
echo "Exxit ....."
sleep 5
clear
exit 1
fi
read -p"Nhap Ten Trang Web Ban Muon Them: " domain
if [ "\$domain" = "" ]; then
echo "Domain khong duoc la rong"
echo "Vui Long Nhap Lai"
sleep 5
sh \$tf
exit 1
fi
checkdm=\`ls /etc/httpd/conf.d/ | grep \$domain\`
if [ "\$checkdm" != "" ]; then
echo "Domain nay da ton tai, vui long nhap lai domain khac."
echo "Neu Ban Muon Thoat ra, vui long an Ctrl + C de thoat".
sleep 5
sh \$tf
exit 1
fi
homedr="/var/www/html/\$domain"
mkdir -p /var/www/html/\$domain
cat > /etc/httpd/conf.d/\$domain.conf << newdomain
<VirtualHost *:80>
ServerAdmin admin@\$domain
DocumentRoot \$homedr
ServerName \$domain
</VirtualHost>
newdomain

/etc/init.d/httpd reload
chkconfig httpd on
exit 1
eof

chmod +x /usr/bin/vhost

echo "configure success full"
echo "reboot system from 3s"
sleep 3
reboot