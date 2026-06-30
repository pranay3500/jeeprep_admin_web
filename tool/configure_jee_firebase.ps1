# Wire jeeprep_admin_web to Firebase project jee-prep-app-16bd5 (FlutterFire).
# Prerequisite: Firebase CLI logged-in account must have access to jee-prep-app-16bd5.
# In Firebase Console -> Project settings -> Users and permissions -> Add member:
#   info@testprepkart.com  (Role: Editor)
#
# Usage:
#   powershell -File tool\configure_jee_firebase.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

. "$PSScriptRoot\flutter_env.ps1"

$projectId = "jee-prep-app-16bd5"
$flutterfire = Join-Path $env:LOCALAPPDATA "Pub\Cache\bin\flutterfire.bat"
if (-not (Test-Path $flutterfire)) {
  Invoke-Dart -Command pub,global,activate,flutterfire_cli
}

Write-Host "Configuring FlutterFire for $projectId ..." -ForegroundColor Cyan
& $flutterfire configure --project=$projectId --platforms=web --yes
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed. Ensure this Google account can access $projectId in Firebase Console." -ForegroundColor Red
  exit $LASTEXITCODE
}

Write-Host "Done. Rebuild admin: powershell -File deploy_admin.ps1" -ForegroundColor Green
