#!/bin/bash

################################
#Author - Vishal Gawande
################################
#Prerequisite
#OS: CentOS8 Minimal
#Add wftadmin User and Password:
#useradd  wftadmin
#passwd wftadmin
#Create directory /home/wftadmin/download/
#Copy 2023-07-18-ivaap_centro_phase2_v2.10.5.7z and 1ViewerInstallScript.sh to /home/wftadmin/download/
#Logon using wftadmin user
#Add below SUDO permissions
#wftadmin ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/vim, /bin/mount, /bin/cp, /usr/bin/chmod, /usr/bin/vi, /bin/dnf, /bin/yum, /bin/cd, /usr/bin/tar, /usr/bin/make, /bin/rpm, /bin/mv, /bin/chown, /bin/systemctl, /bin/mongo, /usr/bin/netstat, /bin/tail, /usr/bin/touch, /usr/bin/echo, /usr/bin/bash, /bin/pip3, /usr/sbin/usermod, /usr/bin/docker, /usr/bin/firewall-cmd, /usr/bin/7z, /usr/local/bin/docker-compose

#Modify Below Variables as per your set-up:
IDP_SERVER_HOST="http://192.168.0.111:5301/idp/"
system_auth_oidc_authority="http://192.168.0.111:5301/idp"
system_ui_docurl="http://192.168.0.111/RTDM/#/main/DataCenter/DocumentStore/Explorer"
apigateway_proxy_pass="http://192.168.0.111:9205/"


echo "########################################"
echo "Started Viewer Installation"
echo "########################################"
#Install Docker
echo "########################################"
echo "Installing Docker"
echo "########################################"
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf list docker-ce
sudo dnf install docker-ce -y
sudo yum install python3-pip -y
sudo pip3 install --upgrade pip
sudo pip3 install docker-compose
sudo usermod -aG docker wftadmin
sudo systemctl start docker
docker-compose
sudo docker ps -a


#Configure Firewall Rules
echo "########################################"
echo "Configure Firewall Rules"
echo "########################################"
sudo firewall-cmd --list-all
sudo firewall-cmd --zone=public --add-port=9000/tcp --permanent
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

#Install 7z
echo "########################################"
echo "Installing 7z"
echo "########################################"

sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
sudo dnf install p7zip p7zip-plugins -y
sleep 15

#Create ivaap folder and copy to /opt/
echo "########################################"
echo "Extraction files with 7z...."
echo "########################################"
cd /home/wftadmin/download/
sudo 7z e 2023-07-18-ivaap_centro*.7z
sleep 10
sudo tar -xvf ivaap-dir*tar.gz
sleep 10
sudo mv ivaap /opt/

#load docker images
echo "########################################"
echo "Loading Docker Images"
echo "########################################"
cd /home/wftadmin/download/
sudo docker images
sudo docker load -i dockerimages_ivaap-*.tar.gz
sleep 15
sudo docker images

#Modify IVAAP folder
echo "########################################"
echo "Modifying IVAAP folder"
echo "########################################"
#Modify /opt/ivaap/ivaap-containers/nginx/http-prod-nginx.conf
sed -i "s|.*proxy_pass http://10.7.76.135/;|              proxy_pass "$apigateway_proxy_pass";|" /opt/ivaap/ivaap-containers/nginx/http-prod-nginx.conf

#Modify /opt/ivaap/ivaap-containers/viewer2/systemconfig.json
sed -i "s|.*"system.ui.docurl".*|  \"system.ui.docurl\": \""$system_ui_docurl"\",|" /opt/ivaap/ivaap-containers/viewer2/systemconfig.json
sed -i "s|.*"system.auth.oidc.authority".*|  \"system.auth.oidc.authority\": \""$system_auth_oidc_authority"\",|" /opt/ivaap/ivaap-containers/viewer2/systemconfig.json
sed -i "s|.*"system.auth.oidc.clientId".*|  \"system.auth.oidc.clientId\": \"CENTRO Viewer Publish\",|" /opt/ivaap/ivaap-containers/viewer2/systemconfig.json


#Modify /opt/ivaap/ivaap-containers/viewer/systemconfig.json
sed -i "s|.*"system.ui.docurl".*|  \"system.ui.docurl\": \""$system_ui_docurl"\",|" /opt/ivaap/ivaap-containers/viewer/systemconfig.json
sed -i "s|.*"system.auth.oidc.authority".*|  \"system.auth.oidc.authority\": \""$system_auth_oidc_authority"\",|" /opt/ivaap/ivaap-containers/viewer/systemconfig.json
sed -i "s|.*"system.auth.oidc.clientId".*|  \"system.auth.oidc.clientId\": \"CENTRO Viewer\",|" /opt/ivaap/ivaap-containers/viewer/systemconfig.json


#Modify /opt/ivaap/ivaap-containers/admin/systemconfig.json
sed -i "s|.*"system.auth.oidc.authority".*|  \"system.auth.oidc.authority\": \""$system_auth_oidc_authority"\",|" /opt/ivaap/ivaap-containers/admin/systemconfig.json
sed -i "s|.*"system.auth.oidc.clientId".*|  \"system.auth.oidc.clientId\": \"CENTRO Viewer Admin\",|" /opt/ivaap/ivaap-containers/admin/systemconfig.json


#Modify /opt/ivaap/ivaap-containers/admin/IVAAPConfig.json
sed -i "s|.*"system.auth.oidc.authority".*|  \"system.auth.oidc.authority\": \""$system_auth_oidc_authority"\",|" /opt/ivaap/ivaap-containers/admin/IVAAPConfig.json
sed -i "s|.*"system.auth.oidc.clientId".*|  \"system.auth.oidc.clientId\": \"CENTRO Viewer Admin\",|" /opt/ivaap/ivaap-containers/admin/IVAAPConfig.json

#Modify /opt/ivaap/ivaap-containers/conf/ivaap-common-properties.env
IDP_SERVER_HOST="http://192.168.0.111:5301/idp/"
sed -i "s|^IVAAP_COMMON_WEATHERFORD_IDP_SERVER_HOST.*|IVAAP_COMMON_WEATHERFORD_IDP_SERVER_HOST="$IDP_SERVER_HOST"|" /opt/ivaap/ivaap-containers/conf/ivaap-common-properties.env

#Set Permissions
echo "########################################"
echo "Setting up Permissions"
echo "########################################"
cd /opt/ivaap/ivaap-volumes
sudo chown -R $USER:$USER logs
cd /opt/ivaap/ivaap-volumes/logs
sudo chown 1999:1999 activemq
sudo chown 999:999 postgres
sudo chown 101:101 proxy
sudo chown 1999:1999 jivaapserver
sudo chown 1999:1999 nodejs


#Modify  /opt/ivaap/ivaap-containers/docker-compose.yml file to start postgres container
echo "########################################"
echo "Uncomment line for pgdump_init.sql"
echo "########################################"
sed -i '/^#.*pgdump_init.*$/s/^#\ / /' /opt/ivaap/ivaap-containers/docker-compose.yml

echo "########################################"
echo "Building postgres container"
echo "########################################"

cd /opt/ivaap/ivaap-containers/
sudo docker compose down
sudo docker compose build --no-cache
sudo docker compose up -d postgres

echo "########################################"
echo "Commenting line for pgdump_init.sql"
echo "########################################"
sed -i '/[^#]/ s/\(.*pgdump_init.*$\)/#\ \1/' /opt/ivaap/ivaap-containers/docker-compose.yml

#Verify database has got created
echo "########################################"
echo "Verify database has got created"
echo "########################################"
ls -la /opt/ivaap/ivaap-volumes
sudo docker ps -a
sleep 10

#Create and Start all other Containers
echo "########################################"
echo "Starting All Other Containers... Please wait.........."
echo "########################################"
cd /opt/ivaap/ivaap-containers/
sudo docker compose up -d
Sleep 60
sudo docker ps -a

echo "########################################"
echo "Installation Completed"
echo "Now add Viewer entries in RTDM Server for Onsync-IDP > identityServer and Onsync-IDP > home "
echo "########################################"
