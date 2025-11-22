#!/bin/bash

# Command: add
cmd_add() {
    check_session
    
    SERVICE="$1"
    if [ -z "$SERVICE" ]; then
        read -p "Service: " SERVICE
    fi
    
    EXISTS=$(db_query "SELECT count(*) FROM entries WHERE service='$SERVICE';")
    if [ "$EXISTS" -gt 0 ]; then
        echo "Error: Service '$SERVICE' already exists."
        exit 1
    fi

    read -p "Username: " USERNAME
    
    read -p "Generate password? (y/n): " GEN
    if [[ "$GEN" =~ ^[Yy]$ ]]; then
        read -p "Length (default 20): " LEN
        LEN=${LEN:-20}
        PASSWORD=$(openssl rand -base64 48 | cut -c1-$LEN)
        echo "Generated Password: $PASSWORD"
    else
        read -s -p "Password: " PASSWORD
        echo
    fi

    # Encrypt
    ENCRYPTED=$(encrypt_data "$PASSWORD")
    
    sqlite3 "$DB_FILE" "INSERT INTO entries (service, username, encrypted_password, updated_at) VALUES ('$SERVICE', '$USERNAME', '$ENCRYPTED', datetime('now'));"
    
    if [ $? -eq 0 ]; then
        echo "Entry added successfully."
        log_audit "ADD" "$SERVICE"
    else
        echo "Error: Failed to add entry."
        exit 1
    fi
}

cmd_list() {
    check_session
    
    echo "Services in vault:"
    echo "------------------"
    db_query_formatted "SELECT service, username, updated_at FROM entries;"
}
