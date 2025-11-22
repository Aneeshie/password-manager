#!/bin/bash

cmd_edit() {
    check_session
    
    SERVICE="$1"
    if [ -z "$SERVICE" ]; then
        read -p "Service: " SERVICE
    fi
    
    EXISTS=$(db_query "SELECT count(*) FROM entries WHERE service='$SERVICE';")
    if [ "$EXISTS" -eq 0 ]; then
        echo "Error: Service '$SERVICE' not found."
        exit 1
    fi
    
    echo "Editing service: $SERVICE"
    echo "1. Edit Username"
    echo "2. Edit Password"
    echo "3. Cancel"
    read -p "Choice: " CHOICE
    
    case "$CHOICE" in
        1)
            read -p "New Username: " NEW_USER
            db_query "UPDATE entries SET username='$NEW_USER', updated_at=datetime('now') WHERE service='$SERVICE';"
            echo "Username updated."
            log_audit "EDIT" "$SERVICE"
            ;;
        2)
            read -s -p "New Password: " NEW_PASS
            echo
            ENCRYPTED=$(encrypt_data "$NEW_PASS")
            db_query "UPDATE entries SET encrypted_password='$ENCRYPTED', updated_at=datetime('now') WHERE service='$SERVICE';"
            echo "Password updated."
            log_audit "EDIT" "$SERVICE"
            ;;
        *)
            echo "Cancelled."
            ;;
    esac
}

cmd_delete() {
    check_session
    
    SERVICE="$1"
    if [ -z "$SERVICE" ]; then
        read -p "Service: " SERVICE
    fi
    
    EXISTS=$(db_query "SELECT count(*) FROM entries WHERE service='$SERVICE';")
    if [ "$EXISTS" -eq 0 ]; then
        echo "Error: Service '$SERVICE' not found."
        exit 1
    fi
    
    read -p "Are you sure you want to delete '$SERVICE'? (y/n): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        db_query "DELETE FROM entries WHERE service='$SERVICE';"
        echo "Service deleted."
        log_audit "DELETE" "$SERVICE"
    else
        echo "Cancelled."
    fi
}
