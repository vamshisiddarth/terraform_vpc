#!/bin/sh
set -e
sudo yum update -y
sudo yum install -y httpd
sudo service httpd start
echo "<html><h1>This is a Test Page. Your Terraform worked!!!</h1></html>" > /tmp/index.html
sudo mv /tmp/index.html /var/www/html/index.html
