Assignment8-CloudStorage

This repository will build an EC2 image that contains a mysql server with an mysql-backup shell script.  When executed, the shell script will take a snapshot of an example mysql database and table (in this case the recommend.movies table), and save the snapshot to an S3 bucket. The shell script can be run on-demand or as a periodic cron job for regular backups. 

The repository is designed to build via the command-line using the stand-alone packer tools. This is not currently configured to use terraform or GitHub actions, only the packer tool from the command line and to demostrate the elements of using S3.  This script is not compatible with Assignment 4/5 webapp as-is, as it would need to modified to work with attaching your EBS volume. 

Prerequsites: 

On the development host:
packer 

On AWS:
vpc, public subnet and sg setup for an AWS region

This script uses environment variables as the source for passwords and secrets, so your shell should have the following variables set on your development host (e.g. export <variable>=<value>) :

MYSQL_USER
MYSQL_PASS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
Note that the AWS access/secret that you use should allows S3 access. 


To execute packer on the development host:

$packer build --var="mysql_user=${MYSQL_USER}"  --var="mysql_password=${MYSQL_PASS}" --var="aws_access_key_id=${AWS_ACCESS_KEY_ID}"  --var="aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}"  mysql_backup.json.pkr.hcl


The components:

mysql_backup.json.pkr.hcl - The packer HCL file.  This will create an AMI image with mysql-server and the backup script installed.  Once the AMI is created, you can ssh into the instance to run the backup.   This file needs to be configured  with  aws region, instance type, source_ami and s3 bucket name that you want to use. 

data/recommend.sql.gz - an example database and table for use in this example (the recommend.movie table). This file is used only for initializing the database. 

scripts/setup-mysql.sh - The packer setup script to install mysql-server, mysql-client and the aws cli into the AMI image. It also installs all the required credentials (mysql and aws) into the image that are needed for the backup script.

backup_mysql.sh - the backup script that will take a snapshot of the mysql table and send the snapshot to an S3 Bucket.  To run this script, ssh into the instance and run $ ./backup_mysql.sh.  A snapshot of the database will be generated ( recommend-<timestamp>.sql.gz ) and it will be copied to the S3 bucket. All the backup files will be created in the "backups/" on the EC2 instance, along with a log of backup activity. 

