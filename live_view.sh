#!/bin/bash

# this file is for monitoring the application..


VAULT_DIR="$HOME/.vault"

# Loop forever
while true; do
    clear
    echo "=========================================="
    echo "      VAULT LIVE MONITOR"
    echo "=========================================="
    echo "Time: $(date '+%H:%M:%S')"
    echo "Watching: $VAULT_DIR"
    echo "------------------------------------------"
    
    if [ -d "$VAULT_DIR" ]; then
        
        
        ls -lA "$VAULT_DIR" | awk '{print $9, $5, $6, $7, $8}' | grep -v "^ " 
        
        echo "------------------------------------------"
        
        
        if [ -f "$VAULT_DIR/.session" ]; then
            echo " STATUS: UNLOCKED"
            echo "   [!] .session file is PRESENT"
            echo "   [!] This file contains the decryption key."
            echo "   [!] Notice it disappears when you run './vault lock'"
        else
            echo " STATUS: LOCKED"
            echo "   [✓] .session file is GONE"
            echo "   [✓] No decryption is possible right now."
        fi
    else
        echo "Vault directory not found. Run './vault init' first."
    fi
    
    echo "=========================================="
    echo "Press Ctrl+C to stop."
    
    # Refresh every 0.5 seconds
    sleep 0.5
done
