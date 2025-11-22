#!/bin/bash

# Constants
VAULT_DIR="$HOME/.vault"
DB_FILE="$VAULT_DIR/vault.db"
SESSION_FILE="$VAULT_DIR/.session"

# Ensure vault directory exists
mkdir -p "$VAULT_DIR"

# Helper: Log to audit table
log_audit() {
    local action="$1"
    local service="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    sqlite3 "$DB_FILE" "INSERT INTO audit (action, service, timestamp) VALUES ('$action', '$service', '$timestamp');"
}
