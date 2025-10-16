#!/bin/bash

# Check if migration name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <migration_name>"
    echo "Example: $0 AddUserTable"
    exit 1
fi

MIGRATION_NAME="$1"

# DB service provider name
SERVICE="mysql"

echo "--- Attempting to start $SERVICE service ---"

# Attempt to start mysql but if docker-compose doesn't
# exist just trust that the user has it running some other way
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose --profile $SERVICE up -d --no-recreate
fi

dotnet tool restore

# Define providers
declare -A providers=(
    ["MySql"]="../util/MySqlMigrations"
    ["Postgres"]="../util/PostgresMigrations"
    ["Sqlite"]="../util/SqliteMigrations"
)

# Run migrations for each provider
for provider in "${!providers[@]}"; do
    echo "--- START $provider ---"
    dotnet ef migrations add "$MIGRATION_NAME" -s "${providers[$provider]}"
    echo "--- END $provider ---"
done
