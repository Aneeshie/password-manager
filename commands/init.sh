#!/bin/bash

cmd_init() {
    if [ -f "$DB_FILE" ]; then
        echo "Error: Vault already initialized at $DB_FILE"
        exit 1
    fi

    echo "Initializing new vault..."
    
    # Prompt for master password
    read -s -p "Enter master password: " PASS1
    echo
    read -s -p "Confirm master password: " PASS2
    echo

    if [ "$PASS1" != "$PASS2" ]; then
        echo "Error: Passwords do not match."
        exit 1
    fi

    if [ -z "$PASS1" ]; then
        echo "Error: Password cannot be empty."
        exit 1
    fi

    # Generate salt (16 bytes hex)
    SALT=$(openssl rand -hex 16)

    # Hash password for verification
    HASH=$(echo -n "${SALT}${PASS1}" | openssl dgst -sha256 | awk '{print $2}')

    # Create DB
    sqlite3 "$DB_FILE" <<EOF
CREATE TABLE config (
    key TEXT PRIMARY KEY,
    value TEXT
);
CREATE TABLE entries (
    service TEXT PRIMARY KEY,
    username TEXT,
    encrypted_password TEXT,
    iv TEXT,
    updated_at TEXT
);
CREATE TABLE audit (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action TEXT,
    service TEXT,
    timestamp TEXT
);
INSERT INTO config (key, value) VALUES ('salt', '$SALT');
INSERT INTO config (key, value) VALUES ('master_hash', '$HASH');
EOF

    if [ $? -eq 0 ]; then
        echo "Vault initialized successfully."
        log_audit "INIT" "SYSTEM"
    else
        echo "Error: Failed to initialize database."
        rm -f "$DB_FILE"
        exit 1
    fi
}
