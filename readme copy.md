# resource developer 
# https://contributing.bitwarden.com/getting-started/server/guide


# Configure Git
git config blame.ignoreRevsFile .git-blame-ignore-revs
git config --local core.hooksPath .git-hooks

# Configure Docker

cd dev
cp .env.example .env

# Start the Docker containers.

docker compose --profile mssql --profile mail up -d

docker compose --profile mssql --profile mail --profile storage --profile mariadb up -d

# will delete your development database

docker compose --profile mssql down
docker volume rm bitwardenserver_mssql_dev_data
# ---------------------------------------------------------
# Azurite

cd dev
npm install -g azurite

# ---------------------------------------------------------
# Run API

Write-Host "Attempting to terminate existing .NET host and Visual Studio Debug Adapter processes..."


Get-Process | Where-Object {$_.ProcessName -like "*dotnet*" -or $_.ProcessName -like "*Bitwarden.Api*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Get-Process | Where-Object {$_.ProcessName -like "*VsDebugConsole*" -or $_.ProcessName -like "*msvsmon*"} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "Cleaning the project..."
dotnet clean C:\Users\wahhan\Desktop\Bitwarden configration\server\src\Api

Write-Host "Restoring NuGet packages..."
dotnet restore C:\Users\wahhan\Desktop\Bitwarden configration\server\src\Api

Write-Host "Running the Bitwarden API project..."
cd C:\Users\wahhan\Desktop\Bitwarden configration\server\src\Api
dotnet run

# ---------------------------------------------------------
###  Advanced Server Setup
# Premium Features
Connect to your local server with the web client.
When purchasing a subscription or premium, use the credit card payment method using testing data from :
https://docs.stripe.com/testing?testing-method=card-numbers#cards

# File Uploads (File Sends and Attachments)

mkdir C:\BitwardenStorage\send
mkdir C:\BitwardenStorage\attachments


## CREATE FILE appsettings.override.json

{
  "globalSettings": {
    "send": {
      "baseDirectory": "C:/BitwardenStorage/send",
      "baseUrl": "file:///C:/BitwardenStorage/send"
    },
    "attachment": {
      "baseDirectory": "C:/BitwardenStorage/attachments",
      "baseUrl": "file:///C:/BitwardenStorage/attachments"
    }
  }
}



## PayPal


## YubiKey 2FA
Acquire a ClientId and Key from Yubico here. Note that this requires that you have a YubiKey in order to provide an OTP. If you do not have a YubiKey please contact your manager

 https://upgrade.yubico.com/getapikey/


 ## ---------------------------------- Reverse Proxy Setup -----------

cd dev
cp reverse-proxy.conf.example reverse-proxy.conf
# ------------------           code reverse proxy
 Begin API Service

upstream api_loadbalancer {
    # Add additional API services here uniquely identified by their port
    # Below assumes two services running on the docker host machine on ports 4000 and 4002
    server host.docker.internal:4000;
    server host.docker.internal:4002;
}

server {
    listen 4100; # The port clients will connect to for the Api, must be exposed via Docker
    location / {
        proxy_pass http://api_loadbalancer;
    }
}

# End API Service

# Begin Identity Service

upstream identity_loadbalancer {
    # Add additional Identity services here uniquely identified by their port
    # Below assumes two services running on the docker host machine on ports 33656 and 33658
    server host.docker.internal:33656;
    server host.docker.internal:33658;
}

server {
    listen 33756; # The port clients will connect to for the Identity, must be exposed via Docker
    location / {
        proxy_pass http://identity_loadbalancer;
    }
}

# End Identity Service
# ------------------           .env
# Optional reverse proxy configuration
# Should match server listen ports in reverse-proxy.conf
API_PROXY_PORT=4100
IDENTITY_PROXY_PORT=33756

# Command line (in separate terminals)
# 1st instance
cd src/Api
dotnet run --urls=http://localhost:4000/
# 2nd instance: --no-build can avoid conflicts with the first instance
cd src/Api
dotnet run --urls=http://localhost:4002/ --no-build
 ## ----------------------------------------------------------
# NuGet with GitHub Packages
generate a GitHub personal access token (classic) with the packages:read 
# --------------- windows
# step  1
$GITHUB_PAT = Read-Host -AsSecureString "Enter your GitHub Personal Access Token"

# step 2

$PlainToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($GITHUB_PAT)
)
# step 3
dotnet nuget add source `
  --username bitwarden `
  --password $PlainToken `
  --store-password-in-clear-text `
  --name github `
  "https://nuget.pkg.github.com/bitwarden/index.json"


# ------------------------  Database  mssql
# ------------ 1 cd dev

pwsh setup_secrets.ps1 -clear
docker compose --profile mssql down
docker volume rm bitwardenserver_mssql_dev_data
docker compose --profile mssql up -d
-------------- 
pwsh migrate.ps1
# ------------ 2  server\util\MsSqlMigratorUtility\
dotnet build
# ------------ 3 cd dev
pwsh migrate.ps1





//--------------------------- run project
Desktop\Bitwarden configration\server> dotnet build
Desktop\Bitwarden configration\server> dotnet run --project src\Api

//-------------------------