#!/bin/sh

#  apache_vsftpd.sh
#  
#
#  Created by HSP SI Viet Nam on 6/28/14.
#
clear
if [ $(id -u) != "0" ]; then
printf "Error: Ban khong phai la supper admin!\n"
printf "Vui long dang nhap bang tai khoan supper admin de co the tien hanh cai dat!\n"
sleep 3
exit
fi

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
myip=`ifconfig $(route -n | grep UG | awk '{print $8}') | grep 'inet addr:' | awk '{print $2}' | sed 's/addr://g'`
mylink=`echo $0`
myfolder=`pwd`
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

#check vsftpd install
check_vsftpd=`rpm -qa | grep vsftpd`
if [ "$check_vsftpd" != '' ]; then
yum -y remove $check_vsftpd >> ~/log_remove
fi
echo "Install vsftpd"
echo "Please Wait....."
yum -y install vsftpd >> ~/log_Install

#check epel release 6.8
check_epel=`rpm -qa | grep epel`
if [ "$check_epel" = '' ]; then
echo "Install epel"
echo "Please Wait....."
yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm >> ~/log_Install
fi

#install ntp
check_ntp=`rpm -qa | grep ntp`
if [ "$check_ntp" = "" ]; then
echo "Install ntp"
echo "Please Wait....."
yum -y install ntp >> ~/log_Install
fi

#install phpmyadmin
echo "install phpMyAdmin"
echo "Please Wait....."
wget -o ~/log_Install https://github.com/vietshell/Linux_Script/raw/master/mysql%205.7/phpMyAdmin-4.2.5-all-languages.tar.gz
tar -xvf phpMyAdmin-4.2.5-all-languages.tar.gz >> ~/log_Install
rm -rf phpMyAdmin-4.2.5-all-languages.tar.gz
mv phpMyAdmin-4.2.5-all-languages/ /usr/share/admindb

#install module php
#yum -y install php-* --skip-broken php-pecl-zendopcache php-xcache php-pecl-http php-pecl-apc php-pecl-apcu php-xcache php-pecl-zendopcache php-pecl-http1-devel php-xcache php-ZendFramework2-common php-pecl-apcu-devel php-pecl-gmagick php-pecl-http1 >> >> ~/log_Install

#change timezone VN
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
ntpdate pool.ntp.org
echo ""
echo "Install package success"
echo "Setting apache"
sleep 3

#configure httpdls

mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.bk
sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/httpd/conf/httpd.conf
sed -i 's/KeepAlive Off/KeepAlive On/g' /etc/httpd/conf/httpd.conf
sed -i 's/\#ServerName www.example.com:80/ServerName $myip\:80/g' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
sed -i 's/Options Indexes FollowSymLinks/Options -Indexes FollowSymLinks/g' /etc/httpd/conf/httpd.conf
sed -i 's/DirectoryIndex index.html index.html.var/DirectoryIndex index.html index.php index.cgi/g' /etc/httpd/conf/httpd.conf
sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/httpd/conf/httpd.conf
sed -i 's/\#NameVirtualHost \*:80/NameVirtualHost \*:80/g' /etc/httpd/conf/httpd.conf

#create vhost
cat > /etc/httpd/conf.d/1.conf << eof
<VirtualHost *:80>
ServerAdmin root@$myip
DocumentRoot /var/www/html
ServerName $myip
ErrorLog logs/$myip-error_log
CustomLog logs/$myip-access_log common
</VirtualHost>
eof



#configure vsftpd
cat > /etc/vsftpd/vsftpd.conf << eof
anonymous_enable=NO
hide_ids=YES
user_sub_token=\$USER
local_root=/home/\$USER/
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
chroot_local_user=YES
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES

eof

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
tf=\`echo \$0\`
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

#password user
prompt1="Create New Password:"
while IFS= read -p "\$prompt1" -r -s -n 1 char1
do
if [[ \$char1 == \$'\0' ]]
then
break
fi
prompt1='*'
pass1+="\$char1"
done
echo ""

#password user relep
prompt2="Type Password again:"
while IFS= read -p "\$prompt2" -r -s -n 1 char2
do
if [[ \$char2 == \$'\0' ]]
then
break
fi
prompt2='*'
pass2+="\$char2"
done
echo ""

#check password
if [ "\$pass1" != "\$pass2" ]; then
echo "Error: Password khong khop"
echo "Chuong trinh se tu dong thoat"
echo "Good Bye"
sleep 5
exit 1
fi
useradd -s /sbin/nologin \$domain
echo \$pass1 | passwd \$domain --stdin
homedr=\`awk -F':' '{ print \$6}' /etc/passwd | grep \$domain\`
mkdir -p \$homedr/public_html
cat > /etc/httpd/conf.d/\$domain.conf << newdomain
<VirtualHost *:80>
ServerAdmin admin@\$domain
DocumentRoot \$homedr/public_html
ServerName \$domain
ErrorLog logs/\$domain-error_log
CustomLog logs/\$domain-access_log common
Alias /admindb "/usr/share/admindb"
</VirtualHost>
newdomain

cat > \$homedr/public_html/index.php << newindex
<h3>Welcome to \$domain</h3>
newindex
chmod -R u=rwx,g=rwx \$homedr
chown -R \$domain:apache \$homedr

/etc/init.d/httpd reload
chkconfig httpd on
exit 1
eof

chmod +x /usr/bin/vhost
iptables -F
/etc/init.d/iptables save
chkconfig httpd on
chkconfig iptables on
chkconfig vsftpd on
echo "configure success full"
echo "reboot system from 3s"
sleep 3
reboot