#!/bin/bash
# MySQL Backup Configuration File

# S3 Bucket Configuration
export MYSQL_S3_BUCKET="${S3_BUCKET:-mwr-db-backup-unique-id}"

# Database Configuration
export DB_NAME="recommend1"
export DB_TABLES="movies"

# Backup Configuration
export RETENTION_DAYS=7
export BACKUP_BASE_DIR="/var/backup/mysql/"
export LOG_BASE_DIR="/var/log"
export MIN_BACKUP_SIZE=1024  # Minimum expected backup size in bytes

# S3 Configuration
export S3_MAX_RETRIES=3
export S3_STORAGE_CLASS="STANDARD"

# Alert Configuration
# Uncomment and set if using SNS for alerts
# export SNS_TOPIC_ARN="arn:aws:sns:region:account-id:topic-name"
