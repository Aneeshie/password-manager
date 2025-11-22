#!/bin/bash

check_session() {
    if [ ! -f "$SESSION_FILE" ]; then
        echo "Error: Vault is locked. Run 'vault unlock' first."
        exit 1
    fi
    return 0
}

get_session_key() {
    cat "$SESSION_FILE"
}

encrypt_data() {
    local data="$1"
    echo -n "$data" | openssl enc -aes-256-cbc -pbkdf2 -a -salt -pass file:"$SESSION_FILE"
}

decrypt_data() {
    local encrypted="$1"
    echo "$encrypted" | openssl enc -d -aes-256-cbc -pbkdf2 -a -pass file:"$SESSION_FILE" 2>/dev/null
}
