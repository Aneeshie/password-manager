#!/bin/bash

# Command: unlock
cmd_unlock() {
    if [ -f "$SESSION_FILE" ]; then
        echo "Vault is already unlocked."
        exit 0
    fi

    if [ ! -f "$DB_FILE" ]; then
        echo "Error: Vault not initialized. Run 'vault init' first."
        exit 1
    fi

    read -s -p "Enter master password: " PASS
    echo

    # Retrieve salt and hash
    SALT=$(db_query "SELECT value FROM config WHERE key='salt';")
    STORED_HASH=$(db_query "SELECT value FROM config WHERE key='master_hash';")

    # Verify
    CHECK_HASH=$(echo -n "${SALT}${PASS}" | openssl dgst -sha256 | awk '{print $2}')

    if [ "$CHECK_HASH" == "$STORED_HASH" ]; then
        echo "Success. Vault unlocked."
        # Store password in session file (restricted)
        touch "$SESSION_FILE"
        chmod 600 "$SESSION_FILE"
        echo -n "$PASS" > "$SESSION_FILE"
        log_audit "UNLOCK" "SYSTEM"
    else
        echo "Error: Invalid password."
        log_audit "FAILED_LOGIN" "SYSTEM"
        exit 1
    fi
}

# Command: lock
cmd_lock() {
    if [ -f "$SESSION_FILE" ]; then
        rm -f "$SESSION_FILE"
        echo "Vault locked."
        log_audit "LOCK" "SYSTEM"
    else
        echo "Vault is already locked."
    fi
}
