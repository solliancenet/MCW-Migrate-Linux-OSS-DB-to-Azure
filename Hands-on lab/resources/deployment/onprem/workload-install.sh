# https://phpipam.net/phpipam-installation-on-centos-7/


# username="demouser"
pwd="demo\!pass123"



### INSTALL PHPIPAM ###

echo "LC_ALL=en_US.utf-8" >> /etc/environment
echo "LANG=en_US.utf-8" >> /etc/environment

sudo yum install -y httpd mariadb-server php php-cli php-gd php-common php-ldap php-pdo php-pear php-snmp php-xml php-mbstring git

sudo yum install php-mysqlnd -y
sudo yum install php-gmp -y




# Update /etc/httpd/conf/httpd.conf
cd /etc/httpd/conf/
wget https://raw.githubusercontent.com/solliancenet/MCW-Migrate-Linux-OSS-DB-to-Azure/lab/Hands-on%20lab/resources/deployment/onprem/httpd.conf


# Start Apache
sudo systemctl start httpd
sudo systemctl enable httpd

sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload

# Start MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Set MariaDB root password
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"${pwd}\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"n\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

# sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${pwd}'; flush privileges;"

# Install phpipam
# Download phpipam release
cd /var/www/html/
wget https://github.com/phpipam/phpipam/releases/download/v1.5.0/phpipam-v1.5.0.zip
unzip phpipam-v1.5.0.zip
mv ./phpipam/* ./
rm -rfv phpipam

sudo chown apache:apache -R /var/www/html/
sudo chcon -t httpd_sys_content_t /var/www/html/

cd /var/www/html/
find . -type f -exec chmod 0644 {} \;
find . -type d -exec chmod 0755 {} \;

sudo chcon -t httpd_sys_rw_content_t app/admin/import-export/upload/ -R
sudo chcon -t httpd_sys_rw_content_t app/subnets/import-subnet/upload/ -R
sudo chcon -t httpd_sys_rw_content_t css/images/logo/ -R

cp config.dist.php config.php
echo "\$allow_untested_php_versions=true;" >> /var/www/html/config.php




# sed -i "s/^\(\$db\['user'\]\s*=\s*\).*\$/\1'${username}';/" config.php
# sed -i "s/^\(\$db\['pass'\]\s*=\s*\).*\$/\1'${pwd}';/" config.php
# sed -i "s/^\(\$db\['name'\]\s*=\s*\).*\$/\1'ipam';/" config.php

# create_db_query="CREATE DATABASE IF NOT EXISTS ipam DEFAULT CHARACTER SET utf8 default COLLATE utf8_bin;"
# SQL_Q1=$(mysql -u root -p ${pwd} -e "${create_db_query}")
# grant_db_query_all="GRANT ALL PRIVILEGES ON ${ipam}.* TO ${username}@'%' IDENTIFIED BY '${pwd}';"
# SQL_Q2=$(mysql -u root -p ${pwd} -e "${grant_db_query_all}")
# grant_db_query_local="GRANT ALL PRIVILEGES ON ipam.* TO ${username}@'localhost' IDENTIFIED BY '${pwd}';"
# SQL_Q3=$(mysql -u root -p ${pwd} -e "${grant_db_query_local}")
