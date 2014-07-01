#!/bin/sh

#  vhost.sh
#  
#
#  Created by HSP SI Viet Nam on 6/28/14.
#
clear
tf=`echo $0`
if [ $(id -u) != "0" ]; then
echo "Ban Khong Phai La Supper User."
echo "Ban Khong Co Quyen Tao VHost"
echo "Vui long dang nhap vao tai khoan Supper User."
echo "Exxit ....."
sleep 5
clear
exit 1
fi
read -p"Nhap Ten Trang Web Ban Muon Them: " domain
if [ "$domain" = "" ]; then
echo "Domain khong duoc la rong"
echo "Vui Long Nhap Lai"
sleep 5
sh $tf
exit 1
fi
checkdm=`ls /etc/httpd/conf.d/ | grep $domain`
if [ "$checkdm" != "" ]; then
echo "Domain nay da ton tai, vui long nhap lai domain khac."
echo "Neu Ban Muon Thoat ra, vui long an Ctrl + C de thoat".
sleep 5
sh $tf
exit 1
fi

#password user
prompt1="Create New Password:"
while IFS= read -p "$prompt1" -r -s -n 1 char1
do
if [[ $char1 == $'\0' ]]
then
break
fi
prompt1='*'
pass1+="$char1"
done
echo ""

#password user relep
prompt2="Type Password again:"
while IFS= read -p "$prompt2" -r -s -n 1 char2
do
if [[ $char2 == $'\0' ]]
then
break
fi
prompt2='*'
pass2+="$char2"
done
echo ""

#check password
if [ "$pass1" != "$pass2" ]; then
echo "Error: Password khong khop"
echo "Chuong trinh se tu dong thoat"
echo "Good Bye"
sleep 5
exit 1
fi
useradd -s /sbin/nologin $domain
echo $pass1 | passwd $domain --stdin
homedr=`awk -F':' '{ print $6}' /etc/passwd | grep $domain`
mkdir -p $homedr/public_html
cat > /etc/httpd/conf.d/$domain.conf << newdomain
<VirtualHost *:80>
ServerAdmin admin@$domain
DocumentRoot $homedr/public_html
ServerName $domain
ErrorLog logs/$domain-error_log
CustomLog logs/$domain-access_log common
Alias /admindb "/usr/share/admindb"
</VirtualHost>
newdomain

cat > $homedr/public_html/index.php << newindex
<h3>Welcome to $domain</h3>
newindex
chmod -R u=rwx,g=rwx $homedr
chown -R $domain:apache $homedr

/etc/init.d/httpd reload
chkconfig httpd on
exit 1