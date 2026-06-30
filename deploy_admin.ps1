# Build JEE Prep Admin for production web hosting.
# After this script finishes, upload EVERYTHING under build\web\ to the server
# that serves https://jeeappadmin.satlas.org/ (replace the old files there).
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\deploy_admin.ps1

param(
  [string]$FlutterBat = "E:\New_TPK_2026\Apps\NEET_Flutter_App\SDK\flutter\bin\flutter.bat"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$OutDir = Join-Path $ProjectRoot "build\web"

if (-not (Test-Path $FlutterBat)) {
  Write-Host "Flutter not found at: $FlutterBat" -ForegroundColor Red
  Write-Host "Edit deploy_admin.ps1 -FlutterBat or install Flutter and use flutter on PATH."
  exit 1
}

Set-Location $ProjectRoot
Write-Host "=== JEE Prep Admin - production web build ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectRoot"
Write-Host ""

& $FlutterBat pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $FlutterBat build web --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$expectedProjectId = "jee-prep-app-16bd5"
$mainJs = Join-Path $OutDir "main.dart.js"
if (-not (Test-Path $mainJs)) {
  Write-Host "Build output missing: $mainJs" -ForegroundColor Red
  exit 1
}
$bundle = Get-Content -Raw -Path $mainJs
if ($bundle -notmatch $expectedProjectId) {
  Write-Host "Build verification failed: main.dart.js missing $expectedProjectId" -ForegroundColor Red
  Write-Host "Run: powershell -File tool\configure_jee_firebase.ps1" -ForegroundColor Yellow
  exit 1
}
foreach ($bad in @("testprepkart-jee-prep", "neet-prep-app-fc7fa")) {
  if ($bundle -match $bad) {
    Write-Host "Build verification failed: main.dart.js references $bad (wrong project)." -ForegroundColor Red
    exit 1
  }
}

$manifest = @{
  app             = "jeeprep_admin_web"
  firebaseProject = $expectedProjectId
  builtAt         = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  mainDartJsBytes = (Get-Item $mainJs).Length
} | ConvertTo-Json -Compress
Set-Content -Path (Join-Path $OutDir "deploy_manifest.json") -Value $manifest -Encoding UTF8

Write-Host ""
Write-Host "Build complete (verified: $expectedProjectId)." -ForegroundColor Green
Write-Host "Output folder - upload ALL of this to your server:" -ForegroundColor Yellow
Write-Host "  $OutDir"
Write-Host "After upload, open:" -ForegroundColor Yellow
Write-Host "  https://jeeappadmin.satlas.org/deploy_manifest.json"
Write-Host "  Must show firebaseProject: $expectedProjectId (not testprepkart-jee-prep)."
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Back up the current live site on the server."
Write-Host "  2. Upload all files from build\web\ to the site document root."
Write-Host "  3. Open https://jeeappadmin.satlas.org/ and hard-refresh."
Write-Host "  4. Sign in and smoke-test one CMS page."
