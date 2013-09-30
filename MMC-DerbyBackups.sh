#!/bin/sh
#
# Original Author: Nicole Green
#
# Program Name: MMC-DerbyBackups
#
# Purpose: Create Database Backups
#
# Dated Revisions: see RCS
#----------------------------------------------------------------------------------------------------------------

 kill -9 `ps aux|grep tomcat|grep java| awk '{ print $2 }'`
#copy
cp -R /usr/local/apache-tomcat-7.0.40/bin/mmc-data  /mnt/mmcbackups/ESBMMC01DB.`date +"%Y%m%d%H%M%S"`.bck
#Find files older than 7 days and delete
find /mnt/mmcbackups/*.bck -mtime +7 -delete
#Remove PID
rm -rf "/usr/local/apache-tomcat-7.0.40/tomcat.pid"


#Start Tomcat Check Status
/etc/init.d/tomcat7 start >/tmp/tomcatstatus.txt
/etc/init.d/tomcat7 status|grep OK
echo $?
if [ $? -eq 0 ]
then
`/bin/mail -s "ESBMMC01 Backup is Complete!  " ESDIntergrationServices\@espn.com< /tmp/tomcatstatus.txt`
else 
`/bin/mail -s "ESBMMC01 Tomcat has failed to start  " ESDIntegrationServices\@espn.com< /tmp/tomcatstatus.txt`;
fi
