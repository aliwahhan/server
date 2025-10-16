#!/bin/bash

# Quick fix for SQLite database path issues
# This script creates the necessary directories and fixes common SQLite path problems

echo "Fixing SQLite database path issues..."

# Get the current directory
CURRENT_DIR=$(pwd)

# Create the db directory if it doesn't exist
DB_DIR="$CURRENT_DIR/db"
echo "Creating database directory: $DB_DIR"
mkdir -p "$DB_DIR"

# Create a default SQLite 

database file
SQLITE_DB="$DB_DIR/deepsafer.db"
echo "Creating SQLite database file: $SQLITE_DB"

# Remove existing file if it exists and create a new one
if [ -f "$SQLITE_DB" ]; then
    echo "Removing existing database file..."
    rm -f "$SQLITE_DB"
fi

# Create the database file
touch "$SQLITE_DB"
chmod 644 "$SQLITE_DB"

echo "✓ SQLite database setup completed!"
echo "Database location: $SQLITE_DB"

# Verify the file was created
if [ -f "$SQLITE_DB" ]; then
    echo "✓ Database file created successfully"
    echo "File details:"
    ls -la "$SQLITE_DB"
else
    echo "✗ Failed to create database file"
    exit 1
fi

echo ""
echo "Now you can run your migrations:"
echo "  ./migrate_enhanced.sh --sqlite"
echo "  ./migrate_enhanced.sh --all"

