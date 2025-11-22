#!/bin/bash

cmd_audit() {
    check_session
    
    echo "Audit Log:"
    echo "----------"
    db_query_formatted "SELECT timestamp, action, service FROM audit ORDER BY timestamp DESC;"
}

cmd_backup() {
    check_session
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="vault_backup_${TIMESTAMP}.enc"
    
    echo "Creating backup: $BACKUP_FILE"
    
    openssl enc -aes-256-cbc -pbkdf2 -salt -pass file:"$SESSION_FILE" -in "$DB_FILE" -out "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Backup created successfully."
        log_audit "BACKUP" "SYSTEM"
    else
        echo "Error: Backup failed."
        exit 1
    fi
}

cmd_restore() {
    BACKUP_FILE="$1"
    if [ -z "$BACKUP_FILE" ]; then
        echo "Usage: vault restore <backup_file>"
        exit 1
    fi
    
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "Error: Backup file '$BACKUP_FILE' not found."
        exit 1
    fi
    
    echo "Restoring from: $BACKUP_FILE"
    echo "Warning: This will overwrite the current vault."
    read -p "Are you sure? (y/n): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    
    read -s -p "Enter master password for this backup: " PASS
    echo
    
    TEMP_DB="${DB_FILE}.restore.tmp"
    openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$PASS" -in "$BACKUP_FILE" -out "$TEMP_DB" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        if sqlite3 "$TEMP_DB" "PRAGMA integrity_check;" &>/dev/null; then
            mv "$TEMP_DB" "$DB_FILE"
            echo "Restore successful."
            rm -f "$SESSION_FILE"
            echo "Vault locked. Please unlock with the restored password."
        else
            echo "Error: Restored file is corrupt or invalid password."
            rm -f "$TEMP_DB"
            exit 1
        fi
    else
        echo "Error: Decryption failed. Invalid password."
        exit 1
    fi
}
