# resource developer
# https://contributing.bitwarden.com/getting-started/server/guide


# Configure Git
git config blame.ignoreRevsFile .git-blame-ignore-revs
git config --local core.hooksPath .git-hooks

# Configure Docker

# --------------------------------   configuration  dev   --------------------------------
# ---------------------------------------- .env
# 1-cp .env.example .env
# ---------------------------------------- secrets.json
# 2-cp secrets.json.example .secrets.json
# ---------------------------------------- reverse-proxy.conf
# 3-cp reverse-proxy.conf.example reverse-proxy.conf
# ---------------------------------------- authsources.php
# 4-cp authsources.php.example authsources.php

# ---------------------------------------- create_certificates_windows
1- pwsh .\create_certificates_windows.ps1
update any certificateThumbprint => Thumbprint certificates
# ---------------------------------------- setup_secrets
2- pwsh .\setup_secrets.ps1


# ---------------------------------------- Docker
# Start the Docker containers.

docker compose --profile mssql --profile mail up -d
pwsh setup_secrets.ps1 -clear

docker compose `
  --profile mssql `
  --profile storage `
  --profile mail `
  --profile postgres `
  --profile mysql `
  --profile mariadb `
  --profile idp `
  --profile rabbitmq `
  --profile proxy `
  --profile servicebus `
  --profile redis `
  up -d
===
  docker compose --profile "*" up -d

  # ---------------------------------------- setup_azurite
pwsh -Command "Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force"
npm install -g azurite
azurite --location c:\azurite_data --debug c:\azurite_data\debug.lo
[pwsh .\setup_azurite.ps1](http://localhost:1080/)

//-------- problrm setup_azurite you can delete old data logos  and create  file and tracing logs
rmdir c:\azurite_data -Recurse -Force
mkdir c:\azurite_data
azurite --location c:\azurite_data --debug c:\azurite_data\debug.lo
pwsh .\setup_azurite.ps1
# ---------------------------------------- migrate
4- pwsh .\migrate.ps1 --all

# will delete your development database

docker compose --profile mssql down
docker volume rm bitwardenserver_mssql_dev_data
docker volume rm deepsaferserver_mssql_dev_data deepsaferserver_postgres_dev_data deepsaferserver_mysql_dev_data deepsaferserver_rabbitmq_data deepsaferserver_redis_data deepsaferserver_mariadb_dev_data


---------------- problem delete volume flex this commend
docker ps -aq | ForEach-Object { docker stop $_; docker rm $_ }

# ---------------------------------------------------------

# ---------------------------------------------------------  RESOVLE PROBLEM 4000 IS AREADE USED
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
dotnet tool uninstall --global dotnet-ef
dotnet tool install --global dotnet-ef
dotnet tool restore
pwsh migrate.ps1 -all
# ------------ 1  mssql migration

pwsh setup_secrets.ps1 -clear
docker compose --profile mssql down
docker volume rm bitwardenserver_mssql_dev_data
docker compose --profile mssql up -d
--------------
pwsh migrate.ps1
# ------------ 2 cd util\MsSqlMigratorUtility\
dotnet build
# كماهو في ملف ال secret.json

dotnet run -- "Server=ALI-WAHHAN-VM\SQLEXPRESS;Database=vault_dev;Integrated Security=True;TrustServerCertificate=True"
# or
dotnet run -- "Server=ALI-WAHHAN-VM\SQLEXPRESS;Database=vault_dev;Integrated Security=True;TrustServerCertificate=True" -r --folder myCustomFolder


Entering experimental data into the database

//--------------------------- run project
Desktop\Bitwarden configration\server> dotnet build
Desktop\Bitwarden configration\server> dotnet run --project src\Api

# //-------------------------    bugs
# ---------------- problem's
fail: Bit.EventsProcessor.AzureQueueHostedService[0]
      Error occurred processing message block.

-------solved
--> Bitwarden configration\server\dev> pwsh .\setup_azurite.ps1
--> Bitwarden configration\server\dev> docker compose --profile servicebus up -d
--> Bitwarden configration\server\src\EventsProcessor> dotnet build
--> Bitwarden configration\server\src\EventsProcessor> dotnet run

# ------------------------------- icon project



# --------------------------------  System Management Portal

 ------ server/src/admin
dotnet restore
npm ci
npm run build
dotnet run


# ---------------------------------   local SSO
server\deepsafer_license\src\Sso> pwsh .\build.ps1
dotnet restore
npm ci
npm run build
dotnet run

# ---------------------------------  Run Projects

cd deepsafer_license/src/sso && dotnet build  && dotnet run
cd deepsafer_license/src/scim && dotnet build  && dotnet run
cd src/admin && npm run build && dotnet build && dotnet run
cd src/api && dotnet build && dotnet run
cd src/Billing && dotnet build && dotnet run
cd src/Events && dotnet build && dotnet run
cd src/EventsProcessor && dotnet build && dotnet run
cd src/Icons && dotnet build && dotnet run
cd src/Identity && dotnet build && dotnet run
cd src/Notifications && dotnet build && dotnet run



# add apikey  test
# link => https://dashboard.stripe.com/apikeys
   "projectName": "Admin",
    "stripe": {
      "apiKey": "sk_test_51RsqAzHBGwJSS6pjOG3Q0qakJa3iJO3DV71eraqVu2G9HGetnwjYepankX3kwqElajx4Lg2xdODcAenX0ePYeSDM00z0kmQagT"
    },

# Make the development certificate trusted on your system
 dotnet dev-certs https --trust

 # if you update key another subsystem you need to delete oilds keys
 this path is : C:\Users\wahhan\AppData\Local\ASP.NET\DataProtection-Keys
# ----------------------------- pass A@limansour1234Ali1234Ali!
