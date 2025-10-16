#!/bin/bash

# Comprehensive Entity Framework migration creation script for Linux
# Supports: MySQL, MariaDB, PostgreSQL, SQLite

# Check if migration name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <migration_name> [options]"
    echo ""
    echo "Options:"
    echo "  --mysql     Create migration for MySQL only"
    echo "  --postgres  Create migration for PostgreSQL only"
    echo "  --sqlite    Create migration for SQLite only"
    echo "  --mariadb   Create migration for MariaDB only"
    echo "  --all       Create migration for all databases (default)"
    echo "  --verbose   Enable verbose output"
    echo "  -h, --help  Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 AddUserTable                    # Create migration for all databases"
    echo "  $0 AddUserTable --mysql --postgres # Create migration for MySQL and PostgreSQL only"
    echo "  $0 AddUserTable --all --verbose    # Create migration for all databases with verbose output"
    exit 1
fi

MIGRATION_NAME="$1"
shift

# Default values
MYSQL_ONLY=false
POSTGRES_ONLY=false
SQLITE_ONLY=false
MARIADB_ONLY=false
ALL_DATABASES=true
VERBOSE=false

# Parse additional arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --mysql)
            MYSQL_ONLY=true
            ALL_DATABASES=false
            shift
            ;;
        --postgres)
            POSTGRES_ONLY=true
            ALL_DATABASES=false
            shift
            ;;
        --sqlite)
            SQLITE_ONLY=true
            ALL_DATABASES=false
            shift
            ;;
        --mariadb)
            MARIADB_ONLY=true
            ALL_DATABASES=false
            shift
            ;;
        --all)
            ALL_DATABASES=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Entity Framework Migration Creation Script"
            echo ""
            echo "Usage: $0 <migration_name> [options]"
            echo ""
            echo "Options:"
            echo "  --mysql     Create migration for MySQL only"
            echo "  --postgres  Create migration for PostgreSQL only"
            echo "  --sqlite    Create migration for SQLite only"
            echo "  --mariadb   Create migration for MariaDB only"
            echo "  --all       Create migration for all databases (default)"
            echo "  --verbose   Enable verbose output"
            echo "  -h, --help  Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 AddUserTable                    # Create migration for all databases"
            echo "  $0 AddUserTable --mysql --postgres # Create migration for MySQL and PostgreSQL only"
            echo "  $0 AddUserTable --all --verbose    # Create migration for all databases with verbose output"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Logging function
log() {
    if [ "$VERBOSE" = true ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    else
        echo "$1"
    fi
}

# DB service provider name
SERVICE="mysql"

log "--- Attempting to start $SERVICE service ---"

# Attempt to start mysql but if docker-compose doesn't
# exist just trust that the user has it running some other way
if command -v docker-compose >/dev/null 2>&1; then
    log "Starting Docker Compose services..."
    docker-compose --profile $SERVICE up -d --no-recreate
else
    log "Docker Compose not found, assuming services are running externally"
fi

log "Restoring .NET tools..."
dotnet tool restore

# Define providers with their configurations
declare -A providers=(
    ["MySql"]="../util/MySqlMigrations"
    ["Postgres"]="../util/PostgresMigrations"
    ["Sqlite"]="../util/SqliteMigrations"
)

# Function to create migration for a specific provider
create_migration() {
    local provider_name="$1"
    local provider_path="$2"
    
    log "--- START $provider_name ---"
    
    # Check if the provider path exists
    if [ ! -d "$provider_path" ]; then
        log "Warning: Provider path $provider_path does not exist, skipping $provider_name"
        return 1
    fi
    
    # Create the migration
    if dotnet ef migrations add "$MIGRATION_NAME" -s "$provider_path"; then
        log "Successfully created migration '$MIGRATION_NAME' for $provider_name"
    else
        log "Error: Failed to create migration '$MIGRATION_NAME' for $provider_name"
        return 1
    fi
    
    log "--- END $provider_name ---"
}

# Determine which providers to process
declare -a providers_to_process=()

if [ "$ALL_DATABASES" = true ]; then
    # Process all providers
    for provider in "${!providers[@]}"; do
        providers_to_process+=("$provider")
    done
else
    # Process only selected providers
    if [ "$MYSQL_ONLY" = true ]; then
        providers_to_process+=("MySql")
    fi
    if [ "$POSTGRES_ONLY" = true ]; then
        providers_to_process+=("Postgres")
    fi
    if [ "$SQLITE_ONLY" = true ]; then
        providers_to_process+=("Sqlite")
    fi
    if [ "$MARIADB_ONLY" = true ]; then
        # MariaDB uses the same migrations as MySQL
        providers_to_process+=("MySql")
    fi
fi

# Validate that at least one provider is selected
if [ ${#providers_to_process[@]} -eq 0 ]; then
    log "Error: No database providers selected"
    exit 1
fi

log "Creating migration '$MIGRATION_NAME' for the following providers:"
for provider in "${providers_to_process[@]}"; do
    log "  - $provider"
done

# Run migrations for each selected provider
success_count=0
total_count=${#providers_to_process[@]}

for provider in "${providers_to_process[@]}"; do
    if create_migration "$provider" "${providers[$provider]}"; then
        ((success_count++))
    fi
done

# Summary
log ""
log "Migration creation summary:"
log "  Total providers: $total_count"
log "  Successful: $success_count"
log "  Failed: $((total_count - success_count))"

if [ $success_count -eq $total_count ]; then
    log "All migrations created successfully!"
    exit 0
else
    log "Some migrations failed to create. Check the output above for details."
    exit 1
fi
