#!/bin/bash

# Command: get
cmd_get() {
    check_session
    
    SERVICE="$1"
    if [ -z "$SERVICE" ]; then
        read -p "Service: " SERVICE
    fi
    
    # Fetch encrypted password
    ENCRYPTED=$(db_query "SELECT encrypted_password FROM entries WHERE service='$SERVICE';")
    
    if [ -z "$ENCRYPTED" ]; then
        echo "Error: Service '$SERVICE' not found."
        exit 1
    fi
    
    # Decrypt
    DECRYPTED=$(decrypt_data "$ENCRYPTED")
    
    if [ $? -ne 0 ]; then
        echo "Error: Decryption failed. Session key might be invalid."
        exit 1
    fi
    
    echo "Service: $SERVICE"
    echo "Select action:"
    echo "  [r] Reveal password"
    echo "  [c] Copy to clipboard"
    echo "  [q] Quit"
    read -p "Action: " ACTION
    
    case "$ACTION" in
        r|R)
            echo "Password: $DECRYPTED"
            ;;
        c|C)
            if command -v pbcopy &> /dev/null; then
                echo -n "$DECRYPTED" | pbcopy
                echo "Password copied to clipboard."
            elif command -v xclip &> /dev/null; then
                echo -n "$DECRYPTED" | xclip -selection clipboard
                echo "Password copied to clipboard."
            else
                echo "Error: No clipboard utility found (pbcopy/xclip)."
                echo "Password: $DECRYPTED"
            fi
            ;;
        *)
            echo "Cancelled."
            ;;
    esac
    
    log_audit "VIEW" "$SERVICE"
}

# Command: search
cmd_search() {
    check_session
    
    TERM="$1"
    if [ -z "$TERM" ]; then
        read -p "Search term: " TERM
    fi
    
    echo "Search results for '$TERM':"
    echo "---------------------------"
    db_query_formatted "SELECT service, username, updated_at FROM entries WHERE service LIKE '%$TERM%' OR username LIKE '%$TERM%';"
}
