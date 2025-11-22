#!/bin/bash

# Helper: Execute SQL
db_query() {
    sqlite3 "$DB_FILE" "$1"
}

# Helper: Execute SQL with header and column
db_query_formatted() {
    sqlite3 -header -column "$DB_FILE" "$1"
}
