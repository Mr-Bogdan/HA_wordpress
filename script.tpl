#!/bin/bash
sudo su -i
yum update
yum upgrade
yum install -y httpd
yum install -y mysql
amazon-linux-extras enable php7.4
yum clean metadata
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap}
systemctl restart httpd
systemctl enable httpd
chkconfig httpd on

yum install -y amazon-efs-utils
efs_id="${efs_id}"
mount -t efs $efs_id:/ /var/www/html
echo $efs_id:/ /var/www/html efs defaults,_netdev 0 0 >> /etc/fstab
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www/html
chmod 776 /var/www/html

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
