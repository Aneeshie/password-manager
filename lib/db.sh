#!/bin/bash

db_query() {
    sqlite3 "$DB_FILE" "$1"
}

db_query_formatted() {
    sqlite3 -header -column "$DB_FILE" "$1"
}
