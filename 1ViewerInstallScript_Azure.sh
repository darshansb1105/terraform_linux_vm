#!/bin/bash

################################
#Author - Vishal Gawande
################################
#Prerequisite
#OS: CentOS8 Minimal
#Add wftadmin or any user of your choice and set Password:
#ex: useradd  wftadmin
#ex: passwd wftadmin
#Create download directory under user's home
#ex: Create directory /home/wftadmin/download/
#Copy 2023-07-18-ivaap_centro_phase2_v2.10.5.7z and 1ViewerInstallScript.sh to /home/wftadmin/download/
#Logon using wftadmin user
#Add below SUDO permissions for user
#wftadmin ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/vim, /bin/mount, /bin/cp, /usr/bin/chmod, /usr/bin/vi, /bin/dnf, /bin/yum, /bin/cd, /usr/bin/tar, /usr/bin/make, /bin/rpm, /bin/mv, /bin/chown, /bin/systemctl, /bin/mongo, /usr/bin/netstat, /bin/tail, /usr/bin/touch, /usr/bin/echo, /usr/bin/bash, /bin/pip3, /usr/sbin/usermod, /usr/bin/docker, /usr/bin/firewall-cmd, /usr/bin/7z, /usr/local/bin/docker-compose

#Modify Below Variables as per your set-up:
IDP_SERVER_HOST="http://$1:5301/idp/"
system_auth_oidc_authority="http://$1:5301/idp"
system_ui_docurl="http://$1/RTDM/#/main/DataCenter/DocumentStore/Explorer"
apigateway_proxy_pass="http://$1:9205/"
CHAT_SERVER_HOST="http://$2:3000"

UserName=`/usr/bin/whoami`
OS=`awk -F= '/^ID=/{print $2}' /etc/os-release`

echo "------------------------------Variables-----------------------------" |& tee -a /tmp/Viewer_Installation_Log.txt
echo OS: $OS |& tee -a /tmp/Viewer_Installation_Log.txt
echo User: $UserName |& tee -a /tmp/Viewer_Installation_Log.txt
echo IDP_SERVER_HOST: $IDP_SERVER_HOST |& tee -a /tmp/Viewer_Installation_Log.txt
echo system_auth_oidc_authority: $system_auth_oidc_authority |& tee -a /tmp/Viewer_Installation_Log.txt
echo system_ui_docurl: $system_ui_docurl |& tee -a /tmp/Viewer_Installation_Log.txt
echo apigateway_proxy_pass: $apigateway_proxy_pass |& tee -a /tmp/Viewer_Installation_Log.txt
echo CHAT_SERVER_HOST: $CHAT_SERVER_HOST |& tee -a /tmp/Viewer_Installation_Log.txt
echo "-----------------------------------------------------------------" |& tee -a /tmp/Viewer_Installation_Log.txt

read -p "Do you want to proceed? (yes/no) " choice

if  [ "$choice" = "y" ] || [ "$choice" = "Y" ] || [ "$choice" = "yes" ]; then  #choice

if  [ "$OS" = '"centos"' ]; then #OS

echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Started Viewer Installation On CentOS" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt

#Install Docker
echo "########################################"  |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Installing Docker"  |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo |& tee -a /tmp/Viewer_Installation_Log.txt
sudo dnf list docker-ce |& tee -a /tmp/Viewer_Installation_Log.txt
sudo dnf install docker-ce -y |& tee -a /tmp/Viewer_Installation_Log.txt
sudo yum install python3-pip -y |& tee -a /tmp/Viewer_Installation_Log.txt
sudo pip3 install --upgrade pip |& tee -a /tmp/Viewer_Installation_Log.txt
sudo pip3 install docker-compose |& tee -a /tmp/Viewer_Installation_Log.txt
sudo usermod -aG docker $UserName |& tee -a /tmp/Viewer_Installation_Log.txt
sudo systemctl start docker |& tee -a /tmp/Viewer_Installation_Log.txt
docker-compose |& tee -a /tmp/Viewer_Installation_Log.txt
sudo docker ps -a |& tee -a /tmp/Viewer_Installation_Log.txt

echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Installed docker version" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
sudo docker version |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Installed docker compose version" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
sudo docker compose version |& tee -a /tmp/Viewer_Installation_Log.txt


#Configure Firewall Rules
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Configure Firewall Rules" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
sudo firewall-cmd --list-all |& tee -a /tmp/Viewer_Installation_Log.txt
#sudo firewall-cmd --zone=public --add-port=9000/tcp --permanent
#sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent |& tee -a /tmp/Viewer_Installation_Log.txt
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent |& tee -a /tmp/Viewer_Installation_Log.txt
sudo firewall-cmd --reload |& tee -a /tmp/Viewer_Installation_Log.txt
sudo firewall-cmd --list-all |& tee -a /tmp/Viewer_Installation_Log.txt
#Install 7z
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Installing 7z" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt

sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y |& tee -a /tmp/Viewer_Installation_Log.txt
sudo dnf install p7zip p7zip-plugins -y |& tee -a /tmp/Viewer_Installation_Log.txt
sleep 15

#Create ivaap folder and copy to /opt/
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Extraction files with 7z...." |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
cd /home/$UserName/download/
sudo 7z e 2023-07-18-ivaap_centro*.7z |& tee -a /tmp/Viewer_Installation_Log.txt
sleep 10
sudo tar -xvf ivaap-dir*tar.gz |& tee -a /tmp/Viewer_Installation_Log.txt
sleep 10
sudo mv ivaap /opt/ |& tee -a /tmp/Viewer_Installation_Log.txt

#load docker images
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Loading Docker Images" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
cd /home/$UserName/download/
ls /home/$UserName/download/ |& tee -a /tmp/Viewer_Installation_Log.txt
sudo docker images |& tee -a /tmp/Viewer_Installation_Log.txt
sudo docker load -i dockerimages_ivaap-*.tar.gz |& tee -a /tmp/Viewer_Installation_Log.txt
sleep 15
sudo docker images |& tee -a /tmp/Viewer_Installation_Log.txt

#Modify IVAAP folder
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Modifying IVAAP folder" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
#Modify Viewer License
sudo echo 'LM_LICENSE_FILE={{{FEATURE IVAAPServer INTD 1.0 13-jun-2025 uncounted VENDOR_STRING=users:16 HOSTID=ANY SIGN="0162 1417 DE64 907E 04C8 BB12 EFED 61B7 11C1 1102 1200 2C47 0D20 20D9 94D7 49A5 F1E0 7A4C 44E2 330B D848"}}}' > /opt/ivaap/ivaap-containers/conf/ivaap-license.env

#Modify /opt/ivaap/ivaap-containers/nginx/http-prod-nginx.conf
sed -i "s|.*proxy_pass http://10.7.76.135/;|              proxy_pass "$apigateway_proxy_pass";|" /opt/ivaap/ivaap-containers/nginx/http-prod-nginx.conf  |& tee -a /tmp/Viewer_Installation_Log.txt

#Modify /opt/ivaap/ivaap-containers/viewer2/systemconfig.json
sed -i "s|.*"system.ui.docurl".*|  \"system.ui.docurl\": \""$system_ui_docurl"\",|" /opt/ivaap/ivaap-containers/viewer2/systemconfig.json |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i "s|.*"system.auth.oidc.authority".*|  \"system.auth.oidc.authority\": \""$system_auth_oidc_authority"\",|" /opt/ivaap/ivaap-containers/viewer2/systemconfig.json |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i "s|.*"system.auth.oidc.clientId".*|  \"system.auth.oidc.clientId\": \"CENTRO Viewer Publish\",|" /opt/ivaap/ivaap-containers/viewer2/systemconfig.json |& tee -a /tmp/Viewer_Installation_Log.txt


#Modify /opt/ivaap/ivaap-containers/viewer/systemconfig.json
sed -i "s|.*"system.ui.docurl".*|  \"system.ui.docurl\": \""$system_ui_docurl"\",|" /opt/ivaap/ivaap-containers/viewer/systemconfig.json |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i "s|.*"system.auth.oidc.authority".*|  \"system.auth.oidc.authority\": \""$system_auth_oidc_authority"\",|" /opt/ivaap/ivaap-containers/viewer/systemconfig.json |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i "s|.*"system.auth.oidc.clientId".*|  \"system.auth.oidc.clientId\": \"CENTRO Viewer\",|" /opt/ivaap/ivaap-containers/viewer/systemconfig.json |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i "s|.*"system.chat.host".*|  \"system.chat.host\": \""$CHAT_SERVER_HOST"\",|" /opt/ivaap/ivaap-containers/viewer/systemconfig.json |& tee -a /tmp/Viewer_Installation_Log.txt


#Modify /opt/ivaap/ivaap-containers/admin/systemconfig.json
sed -i "s|.*"system.auth.oidc.authority".*|  \"system.auth.oidc.authority\": \""$system_auth_oidc_authority"\",|" /opt/ivaap/ivaap-containers/admin/systemconfig.json |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i "s|.*"system.auth.oidc.clientId".*|  \"system.auth.oidc.clientId\": \"CENTRO Viewer Admin\",|" /opt/ivaap/ivaap-containers/admin/systemconfig.json |& tee -a /tmp/Viewer_Installation_Log.txt


#Modify /opt/ivaap/ivaap-containers/admin/IVAAPConfig.json
sed -i "s|.*"system.auth.oidc.authority".*|  \"system.auth.oidc.authority\": \""$system_auth_oidc_authority"\",|" /opt/ivaap/ivaap-containers/admin/IVAAPConfig.json |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i "s|.*"system.auth.oidc.clientId".*|  \"system.auth.oidc.clientId\": \"CENTRO Viewer Admin\",|" /opt/ivaap/ivaap-containers/admin/IVAAPConfig.json |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i "s|.*"ivaapchatserver.host".*|  \"ivaapchatserver.host\": \""$CHAT_SERVER_HOST"\",|" /opt/ivaap/ivaap-containers/admin/IVAAPConfig.json |& tee -a /tmp/Viewer_Installation_Log.txt

#Modify /opt/ivaap/ivaap-containers/conf/ivaap-common-properties.env
sed -i "s|^IVAAP_COMMON_WEATHERFORD_IDP_SERVER_HOST.*|IVAAP_COMMON_WEATHERFORD_IDP_SERVER_HOST="$IDP_SERVER_HOST"|" /opt/ivaap/ivaap-containers/conf/ivaap-common-properties.env |& tee -a /tmp/Viewer_Installation_Log.txt

#Set Permissions
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Setting up Permissions" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
cd /opt/ivaap/ivaap-volumes
sudo chown -R $USER:$USER logs |& tee -a /tmp/Viewer_Installation_Log.txt
cd /opt/ivaap/ivaap-volumes/logs
sudo chown 1999:1999 activemq |& tee -a /tmp/Viewer_Installation_Log.txt
sudo chown 999:999 postgres |& tee -a /tmp/Viewer_Installation_Log.txt
sudo chown 101:101 proxy |& tee -a /tmp/Viewer_Installation_Log.txt
sudo chown 1999:1999 jivaapserver |& tee -a /tmp/Viewer_Installation_Log.txt
sudo chown 1999:1999 nodejs |& tee -a /tmp/Viewer_Installation_Log.txt


#Modify  /opt/ivaap/ivaap-containers/docker-compose.yml file to start postgres container
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Uncomment line for pgdump_init.sql" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i '/^#.*pgdump_init.*$/s/^#\ / /' /opt/ivaap/ivaap-containers/docker-compose.yml |& tee -a /tmp/Viewer_Installation_Log.txt

echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Building postgres container" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt

cd /opt/ivaap/ivaap-containers/ 
sudo docker compose down |& tee -a /tmp/Viewer_Installation_Log.txt
sudo docker compose build --no-cache |& tee -a /tmp/Viewer_Installation_Log.txt
sudo docker compose up -d postgres |& tee -a /tmp/Viewer_Installation_Log.txt

echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Commenting line for pgdump_init.sql" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
sed -i '/[^#]/ s/\(.*pgdump_init.*$\)/#\ \1/' /opt/ivaap/ivaap-containers/docker-compose.yml |& tee -a /tmp/Viewer_Installation_Log.txt

#Verify database has got created
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Verify database has got created" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
ls -la /opt/ivaap/ivaap-volumes |& tee -a /tmp/Viewer_Installation_Log.txt
sudo docker ps -a |& tee -a /tmp/Viewer_Installation_Log.txt
sleep 10

#Create and Start all other Containers
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Starting All Other Containers... Please wait.........." |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
cd /opt/ivaap/ivaap-containers/
sudo docker compose up -d |& tee -a /tmp/Viewer_Installation_Log.txt
Sleep 60
sudo docker ps -a |& tee -a /tmp/Viewer_Installation_Log.txt

#Modify nodejs folder permissions |& tee -a /tmp/Viewer_Installation_Log.txt
sudo chown -R 1999:1999 /opt/ivaap/ivaap-volumes/nodejs |& tee -a /tmp/Viewer_Installation_Log.txt

echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Installation Completed" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Now add Viewer entries in RTDM Server for Onsync-IDP > identityServer and Onsync-IDP > home " |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Please open /tmp/Viewer_Installation_Log.txt log file for more logs#
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt

elif  [ "$OS" = '"Ubuntu"' ]; then #OS
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Started Viewer Installation On Ubuntu" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt

else #OS
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
echo "Not a CentOS or Ubuntu exiting..." |& tee -a /tmp/Viewer_Installation_Log.txt
echo "########################################" |& tee -a /tmp/Viewer_Installation_Log.txt
exit 0
fi #OS

elif [ "$choice" = "n" ] || [ "$choice" = "N" ] || [ "$choice" = "no" ]; then  #choice
echo "Making no install" |& tee -a /tmp/Viewer_Installation_Log.txt

else #choice
echo "Wrong Choice..!" |& tee -a /tmp/Viewer_Installation_Log.txt
fi #choice

