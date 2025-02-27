#!/bin/bash
sudo apt-get update
sudo apt-get install -y mysql-server mysql-client unzip curl


# install 
sudo systemctl start mysql
sudo mysql -e "ALTER USER '${MYSQL_USER}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_PASS}';"
sudo mysql -e "FLUSH PRIVILEGES;"

#  save encrypt credentials in .my.cnf (for mysqldump) 
cat << EOF > ~/.my.cnf
[client]
user="${MYSQL_USER}"
password="${MYSQL_PASS}"
host=localhost
EOF

#  import example database (movies table only to keep the size down)
gunzip -c  recommend.sql.gz | mysql 

# installing  aws cli (for S3) 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
mkdir -p .aws

# install the aws credentials and config for aws cli to work. 
cat << EOF > ~/.aws/credentials
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID} 
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY} 
EOF

cat << EOF > ~/.aws/config
[default]
region=us-west-2
output=json
EOF

cat << EOF > ~/config.sh
export MYSQL_S3_BUCKET=${S3_BUCKET}
export DB_NAME="recommend"
export DB_TABLES="movies"
export RETENTION_DAYS=1
EOF


echo "all done"  
