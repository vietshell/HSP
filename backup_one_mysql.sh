#!/bin/sh

#  backup_one_mysql.sh
#  
#
#  Created by HSP SI Viet Nam on 6/27/14.
#
unset db_backup
unset password
echo "Check SYstem"
yum -y install zip >> log_Install
ngay=`date +"%H-%M-%d-%m-%Y"`
clear
read -p "Database Cần Backup:" dbbackup
prompt="Database Password (pass root user):"
while IFS= read -p "$prompt" -r -s -n 1 char
do
if [[ $char == $'\0' ]]
then
break
fi
prompt='*'
password+="$char"
done
clear
#echo "Output:"
#echo "username: $db_backup"
#echo "password: $password"
mysqldump -u root -p$password --add-drop-database $dbbackup > $dbbackup$ngay.sql
zip -r $dbbackup$ngay.zip $dbbackup$ngay.sql
rm -rf $dbbackup$ngay.sql
echo "done"