#!/bin/bash
# backup_mysql.sh - MySQL backup script with S3 upload
# Purpose: Create compressed backup of MySQL database and transfer to S3
# Usage: ./backup_mysql.sh
#
# This script is designed to be run as a cron job by runing the crontab command: 
#   crontab -e 
#   add this line to the cronfile: 
#       0 * * * *  /path/to/backup_mysql.sh
#       
#  Required Installs:
#       aws cli (with access_key and secret set in .aws/credentials) 
#       mysql-server 
#       gzip

#
# some script foo
# this gets the directory where the script is located and 
# sets the  backup and log directorys relative to the script
#
SDIR="$(dirname "$(readlink -f "$0")")"

# read the config file

source ${SDIR}/config.sh

# backup config
S3_BUCKET=${MYSQL_S3_BUCKET}
BACKUP_DIR="${SDIR}/backups/"
LOG_FILE="${BACKUP_DIR}mysql_backup.log"
mkdir -p "${BACKUP_DIR}"


# Create timestamp for unique filename
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="${BACKUP_DIR}${DB_NAME}-${TIMESTAMP}.sql.gz"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

log "Starting MySQL backup of database: ${DB_NAME}"

# Perform database backup
# creates a sql dump file which is then compressed by gzip command. 
# note that this script just backs up the movies, genres and links part in order
# to less the size of the dump file.  
# mysql credentials are in the ~/.my.cnf file
if mysqldump  --single-transaction --quick --lock-tables=false \
    "${DB_NAME}"  ${DB_TABLES}  | gzip > "${BACKUP_FILE}"; then
   log "Database backup completed successfully: ${BACKUP_FILE}"
else
   log "ERROR: Database backup failed"
   exit 1
fi

# Upload to S3
log "Uploading backup to S3 bucket: ${S3_BUCKET}"
if aws s3 cp "${BACKUP_FILE}" "s3://${S3_BUCKET}"; then
   log "S3 upload completed successfully"
else
   log "ERROR: S3 upload failed"
   exit 2
fi

# Clean up old backups (local)
log "Cleaning up backups older than ${RETENTION_DAYS} days"
find "${BACKUP_DIR}" -name "${DB_NAME}-*.sql.gz" -type f -mtime +${RETENTION_DAYS} -delete

log "Backup process completed"
exit 
