#!/bin/bash

# Comprehensive database migration script for Linux
# Supports: MySQL, MariaDB, PostgreSQL, SQLite, Microsoft SQL Server

# Default values
ALL=false
POSTGRES=false
MYSQL=false
MARIADB=false
MSSQL=false
SQLITE=false
SELFHOST=false
TEST=false
VERBOSE=false

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
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Comprehensive Database Migration Script"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --all       Run all database migrations"
            echo "  --postgres  Run PostgreSQL migrations"
            echo "  --mysql     Run MySQL migrations"
            echo "  --mariadb   Run MariaDB migrations"
            echo "  --mssql     Run Microsoft SQL Server migrations"
            echo "  --sqlite    Run SQLite migrations"
            echo "  --selfhost  Use self-hosted configuration"
            echo "  --test      Run test database migrations"
            echo "  --verbose   Enable verbose output"
            echo "  -h, --help  Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --all                    # Run all migrations"
            echo "  $0 --mysql --postgres        # Run MySQL and PostgreSQL migrations"
            echo "  $0 --test --sqlite           # Run SQLite test migrations"
            echo "  $0 --selfhost --mssql        # Run MSSQL with self-hosted config"
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

# Logging function
log() {
    if [ "$VERBOSE" = true ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    else
        echo "$1"
    fi
}

# Function to check if EF database is selected
is_ef_database() {
    [ "$POSTGRES" = true ] || [ "$MYSQL" = true ] || [ "$MARIADB" = true ] || [ "$SQLITE" = true ]
}

# Default to MSSQL if no EF database is selected
if [ "$ALL" = false ] && ! is_ef_database; then
    MSSQL=true
    log "No specific database selected, defaulting to MSSQL"
fi

# Check for Entity Framework tools if needed
if [ "$ALL" = true ] || is_ef_database; then
    log "Checking for Entity Framework Core tools..."
    if ! dotnet ef >/dev/null 2>&1; then
        log "Entity Framework Core tools were not found. Installing dotnet-ef globally..."
        dotnet tool install dotnet-ef -g
    else
        log "Entity Framework Core tools found"
    fi
fi

# Function to get user secrets
get_user_secrets() {
    log "Retrieving user secrets..."
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

# Function to check if connection string is valid
is_valid_connection_string() {
    local conn_str="$1"
    [ -n "$conn_str" ] && [ "$conn_str" != "null" ] && [ "$conn_str" != "" ]
}

# Function to run MSSQL migrations
run_mssql_migrations() {
    local env_name="$1"
    local connection_string="$2"
    
    if is_valid_connection_string "$connection_string"; then
        log "Starting Microsoft SQL Server Migrations for $env_name"
        dotnet run --project ../util/MsSqlMigratorUtility/ "$connection_string"
        log "Microsoft SQL Server Migrations completed for $env_name"
    else
        log "Warning: Invalid connection string for $env_name"
    fi
}

# Function to run EF migrations
run_ef_migrations() {
    local db_name="$1"
    local migration_dir="$2"
    local config_key="$3"
    local db_index="$4"
    
    cd "$CURRENT_DIR/../util/$migration_dir/"
    
    # Run production migrations
    if [ "$TEST" = false ] || [ "$ALL" = true ]; then
        log "Starting $db_name Migrations"
        CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "globalSettings:$config_key:connectionString")
        
        if is_valid_connection_string "$CONNECTION_STRING"; then
            dotnet ef database update --connection "$CONNECTION_STRING"
            log "$db_name Migrations completed"
        else
            log "Warning: Invalid connection string for $db_name"
        fi
    fi
    
    # Run test migrations
    if [ "$TEST" = true ] || [ "$ALL" = true ]; then
        TEST_CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "databases:$db_index:connectionString")
        
        if is_valid_connection_string "$TEST_CONNECTION_STRING"; then
            log "Starting $db_name Migrations for test databases"
            dotnet ef database update --connection "$TEST_CONNECTION_STRING"
            log "$db_name Test Migrations completed"
        else
            log "Warning: Connection string for test $db_name database not found in secrets.json!"
        fi
    fi
    
    cd "$CURRENT_DIR"
}

# Get user secrets once
log "Initializing migration process..."
USER_SECRETS=$(get_user_secrets)

# Run MSSQL migrations
if [ "$ALL" = true ] || [ "$MSSQL" = true ]; then
    log "Processing Microsoft SQL Server migrations..."
    
    if [ "$ALL" = true ] || [ "$TEST" = false ]; then
        if [ "$SELFHOST" = true ]; then
            MS_SQL_CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "dev:selfHostOverride:globalSettings:sqlServer:connectionString")
            ENV_NAME="self-host"
        else
            MS_SQL_CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "globalSettings:sqlServer:connectionString")
            ENV_NAME="cloud"
        fi
        
        run_mssql_migrations "$ENV_NAME" "$MS_SQL_CONNECTION_STRING"
    fi
    
    if [ "$ALL" = true ] || [ "$TEST" = true ]; then
        TEST_MS_SQL_CONNECTION_STRING=$(extract_json_value "$USER_SECRETS" "databases:3:connectionString")
        run_mssql_migrations "test databases" "$TEST_MS_SQL_CONNECTION_STRING"
    fi
fi

# Define database configurations for EF migrations
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
    
    if [ "$should_process" = true ] || [ "$ALL" = true ]; then
        log "Processing $db_name migrations..."
        run_ef_migrations "$db_name" "$migration_dir" "$config_key" "$db_index"
    fi
done

log "All migrations completed successfully!"
