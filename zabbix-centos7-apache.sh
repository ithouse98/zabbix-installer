## setup zabbix
## sh -x zabbix.sh

systemctl stop firewalld
systemctl disable firewalld

## SELINUX=enforcing -> disabled
sed -i 's/SELINUX=enforcing/SELINUX=disabled/'  /etc/selinux/config
setenforce 0

touch /etc/yum.repos.d/MariaDB.repo
echo "[mariadb]" >> /etc/yum.repos.d/MariaDB.repo
echo "name = MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "baseurl = http://yum.mariadb.org/10.4/centos7-amd64" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo


yum makecache fast
yum -y install MariaDB-server MariaDB-client MariaDB-devel

systemctl start mariadb
systemctl enable mariadb

## set password bk201897
mysql_secure_installation <<EOF

n
Y
bk201897
bk201897
y
n
y
y
EOF



## create database
mysql -u root -p"bk201897" -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -u root -p"bk201897" -e "create user 'zabbix'@'%' identified by 'bk201897';"
mysql -u root -p"bk201897" -e "grant all privileges on zabbix.* to 'zabbix'@'%';"
mysql -u root -p"bk201897" -e "flush privileges;"


rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum clean all

yum install -y zabbix-server-mysql zabbix-agent
yum install -y centos-release-scl
yum install -y epel-release


## [zabbix-frontend] --> enabled=1
sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/zabbix.repo


yum install -y zabbix-web-mysql-scl zabbix-apache-conf-scl

zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -pbk201897 zabbix

## setup databse in config file
sed -i 's/# DBPassword=/DBPassword=bk201897/' /etc/zabbix/zabbix_server.conf


## setup time/zone
echo 'php_value[date.timezone] = Asia/Tehran' >>  /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf


systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm


yum install -y httpd httpd-devel
systemctl start httpd
systemctl enable httpd

yum install -y yum-utils
yum-config-manager --enable rhel-server-rhscl-7-rpms
yum install -y centos-release-scl

yum install -y rh-php72-php-bcmath rh-php72-php-fpm rh-php72-php-gd rhphp72-php-ldap rh-php72-php-mbstring rh-php72-php-mysqlnd rh-php72

scl enable rh-php72 bash

systemctl enable rh-php72-php-fpm


yum install -y pcre-devel.x86_64 pcre.x86_64 fping libevent libevent-devel zlib.x86_64 zlib-devel.x86_64 OpenIPMI-devel.x86_64 OpenIPMI-libs.x86_64 OpenIPMI.x86_64 libssh2-devel.x86_64 libssh2.x86_64 libcurl-devel.x86_64 libcurl.x86_64 libxml2-static.x86_64 libxml2.x86_64 libxml2-devel.x86_64 netsnmp-libs.x86_64 net-snmp-devel.x86_64 net-snmp.x86_64 java-headless unixODBC-devel.x86_64 unixODBC.x86_64
