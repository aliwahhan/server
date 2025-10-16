#!/bin/bash

# Default values
ALL=false
POSTGRES=false
MYSQL=false
MARIADB=false
MSSQL=false
SQLITE=false
SELFHOST=false
TEST=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            ALL=true
            shift
            ;;
        --postgres)
            POSTGRES=true
            shift
            ;;
        --mysql)
            MYSQL=true
            shift
            ;;
        --mariadb)
            MARIADB=true
            shift
            ;;
        --mssql)
            MSSQL=true
            shift
            ;;
        --sqlite)
            SQLITE=true
            shift
            ;;
        --selfhost)
            SELFHOST=true
            shift
            ;;
        --test)
            TEST=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --all       Run all database migrations"
            echo "  --postgres  Run PostgreSQL migrations"
            echo "  --mysql     Run MySQL migrations"
            echo "  --mariadb   Run MariaDB migrations"
            echo "  --mssql     Run Microsoft SQL Server migrations"
            echo "  --sqlite    Run SQLite migrations"
            echo "  --selfhost  Use self-hosted configuration"
            echo "  --test      Run test database migrations"
            echo "  -h, --help  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Abort on any error
set -e

CURRENT_DIR=$(pwd)

# Function to check if EF database is selected
is_ef_database() {
    [ "$POSTGRES" = true ] || [ "$MYSQL" = true ] || [ "$MARIADB" = true ] || [ "$SQLITE" = true ]
}

# Default to MSSQL if no EF database is selected
if [ "$ALL" = false ] && ! is_ef_database; then
    MSSQL=true
fi

# Check for Entity Framework tools if needed
if [ "$ALL" = true ] || is_ef_database; then
    if ! dotnet ef >/dev/null 2>&1; then
        echo "Entity Framework Core tools were not found in the dotnet global tools. Attempting to install"
        dotnet tool install dotnet-ef -g
    fi
fi

# Function to get user secrets
get_user_secrets() {
    # The dotnet cli command sometimes adds //BEGIN and //END comments to the output
    # Use grep to remove comments to ensure valid json
    dotnet user-secrets list --json --project "$CURRENT_DIR/../src/Api" | grep -v "^//"
}

# Function to extract JSON value using simple text processing (no jq dependency)
extract_json_value() {
    local json="$1"
    local key="$2"
    
    # Simple JSON value extraction using grep and sed
    echo "$json" | grep -o "\"$key\":[^,}]*" | sed 's/.*"://' | sed 's/"//g' | sed 's/,$//'
}

# Extract connection string from appsettings.Development.json as fallback
extract_appsettings_connection_string() {
    local config_key="$1" # e.g., postgreSql, mySql, sqlite
    local appsettings_path="$CURRENT_DIR/../src/Api/appsettings.Development.json"
    if [ -f "$appsettings_path" ]; then
        # Find the block for the config key and then the connectionString within it
        grep -A 6 -i "\"$config_key\"" "$appsettings_path" | grep -i "connectionString" | head -n1 | sed 's/.*connectionString\"\s*:\s*\"//' | sed 's/\".*$//'
    fi
}

# Run MSSQL migrations
if [ "$ALL" = true ] || [ "$MSSQL" = true ]; then
    if [ "$ALL" = true ] || [ "$TEST" = false ]; then
        USER_SECRETS=$(get_user_secrets)
        if [ "$SELFHOST" = true ]; then
            MS_SQL_CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "dev:selfHostOverride:globalSettings:sqlServer:connectionString")
            ENV_NAME="self-host"
        else
            MS_SQL_CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "globalSettings:sqlServer:connectionString")
            ENV_NAME="cloud"
        fi

        echo "Starting Microsoft SQL Server Migrations for $ENV_NAME"
        dotnet run --project ../util/MsSqlMigratorUtility/ "$MS_SQL_CONNECTION_STRING"
    fi

    if [ "$ALL" = true ] || [ "$TEST" = true ]; then
        TEST_MS_SQL_CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "databases:3:connectionString")
        if [ "$TEST_MS_SQL_CONNECTION_STRING" != "null" ] && [ -n "$TEST_MS_SQL_CONNECTION_STRING" ]; then
            TEST_ENV_NAME="test databases"
            echo "Starting Microsoft SQL Server Migrations for $TEST_ENV_NAME"
            dotnet run --project ../util/MsSqlMigratorUtility/ "$TEST_MS_SQL_CONNECTION_STRING"
        else
            echo "Connection string for a test MSSQL database not found in secrets.json!"
        fi
    fi
fi

# Load user secrets once for EF migrations (needed for connection strings)
USER_SECRETS=$(get_user_secrets)

# Define database configurations
declare -A db_configs=(
    ["postgres"]="PostgreSQL:PostgresMigrations:postgreSql:0"
    ["sqlite"]="SQLite:SqliteMigrations:sqlite:1"
    ["mysql"]="MySQL:MySqlMigrations:mySql:2"
    ["mariadb"]="MariaDB:MySqlMigrations:mySql:3"
)

# Run EF migrations for each database type
for db_type in "${!db_configs[@]}"; do
    IFS=':' read -r db_name migration_dir config_key db_index <<< "${db_configs[$db_type]}"
    
    # Check if this database type should be processed
    case $db_type in
        "postgres")
            should_process=$POSTGRES
            ;;
        "sqlite")
            should_process=$SQLITE
            ;;
        "mysql")
            should_process=$MYSQL
            ;;
        "mariadb")
            should_process=$MARIADB
            ;;
    esac
    
    if [ "$should_process" = false ] && [ "$ALL" = false ]; then
        continue
    fi
    
    cd "$CURRENT_DIR/../util/$migration_dir/"
    
    if [ "$TEST" = false ] || [ "$ALL" = true ]; then
        echo "Starting $db_name Migrations"
        CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "globalSettings:$config_key:connectionString")
        if [ -z "$CONNECTION_STRING" ] || [ "$CONNECTION_STRING" = "null" ]; then
            # Fallback to appsettings.Development.json
            CONNECTION_STRING=$(extract_appsettings_connection_string "$config_key")
        fi
        dotnet ef database update --no-build --connection "$CONNECTION_STRING"
    fi
    
    if [ "$TEST" = true ] || [ "$ALL" = true ]; then
        TEST_CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "databases:$db_index:connectionString")
        if [ "$TEST_CONNECTION_STRING" != "null" ] && [ -n "$TEST_CONNECTION_STRING" ]; then
            echo "Starting $db_name Migrations for test databases"
            dotnet ef database update --no-build --connection "$TEST_CONNECTION_STRING"
        else
            echo "Connection string for a test $db_name database not found in secrets.json!"
        fi
    fi
done

cd "$CURRENT_DIR"
