#!/bin/bash

DB_NAME="cinema_db" 
BACKUP_DIR="/backup" 
DATE=$(date +%Y-%m-%d)

mysqldump -u root -p "$DB_NAME" > "$BACKUP_DIR/$DB_NAME_$DATE.sql"

tar -czf "$BACKUP_DIR/$DB_NAME_$DATE.tar.gz"
"$BACKUP_DIR/$DB_NAME_$DATE.sql"

rm "$BACKUP_DIR/$DB_NAME_$DATE.sql"

echo "Backup completed successfully."