$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "## Building Icons"

Write-Host ""
Write-Host "Building app"
$dotnetVersion = & dotnet --version
Write-Host ".NET Core version $dotnetVersion"

$projectPath = Join-Path $dir 'Icons.csproj'
$outputDir = Join-Path $dir 'obj/build-output/publish'

Write-Host "Restore"
& dotnet restore $projectPath

Write-Host "Clean"
& dotnet clean $projectPath -c "Release" -o $outputDir

Write-Host "Publish"
& dotnet publish $projectPath -c "Release" -o $outputDir
