$projects = @(
    "deepsafer_license/src/sso/Sso.csproj",
    "deepsafer_license/src/scim/Scim.csproj",
    "src/admin/Admin.csproj",
    "src/api/Api.csproj",
    "src/Billing/Billing.csproj",
    "src/Events/Events.csproj",
    "src/EventsProcessor/EventsProcessor.csproj",
    "src/Icons/Icons.csproj",
    "src/Identity/Identity.csproj",
    "src/Notifications/Notifications.csproj"
)

foreach ($proj in $projects) {
    Write-Host "==============================="
    Write-Host " Starting project: $proj "
    Write-Host "==============================="

    dotnet build $proj
    Start-Process powershell -ArgumentList "dotnet run --no-build --no-launch-profile --project $proj"
}
