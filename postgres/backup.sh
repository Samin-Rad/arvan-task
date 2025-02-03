#!/bin/bash


PG_USER="postgres"
PG_PASSWORD="MyPassword"
PG_DATABASE="mydatabase"
BACKUP_DIR="/backup"
BACKUP_FILE="$BACKUP_DIR/postgres-backup-$(date +%Y%m%d-%H%M%S).sql"


mkdir -p $BACKUP_DIR


PGPASSWORD=$PG_PASSWORD pg_dump -U $PG_USER -d $PG_DATABASE -F c -f $BACKUP_FILE


if [ -f "$BACKUP_FILE" ]; then
    echo "Backup created: $BACKUP_FILE"
else
    echo "Backup failed!" >&2
    exit 1
fi


mc cp $BACKUP_FILE minio/postgres-backups/


find $BACKUP_DIR -type f -mtime +7 -exec rm {} \;

echo "Backup uploaded to MinIO successfully!"

