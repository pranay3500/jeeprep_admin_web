# Release build for JEE Prep admin web (output: build/web/)
# Usage: powershell -File tool/build_admin_web.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

. "$PSScriptRoot\flutter_env.ps1"

$expectedProjectId = "jee-prep-app-16bd5"
$forbiddenProjectIds = @(
  "testprepkart-jee-prep",
  "neet-prep-app-fc7fa"
)

Write-Host "JEE Prep Admin Web - release build" -ForegroundColor Cyan
Write-Host "Folder: $(Get-Location)" -ForegroundColor DarkGray
Write-Host "Firebase project: $expectedProjectId" -ForegroundColor DarkGray
Write-Host "Flutter: $script:FlutterSdkRoot" -ForegroundColor DarkGray
Write-Host ""

Invoke-Flutter -Command pub,get
Invoke-Flutter -Command build,web,--release,--no-wasm-dry-run

$mainJs = Join-Path (Get-Location) "build\web\main.dart.js"
if (-not (Test-Path $mainJs)) {
  throw "Build output missing: $mainJs"
}

$content = Get-Content -Raw -Path $mainJs
if ($content -notmatch $expectedProjectId) {
  throw "Build verification failed: main.dart.js does not contain project id '$expectedProjectId'. Re-run tool/configure_jee_firebase.ps1 and rebuild."
}
foreach ($bad in $forbiddenProjectIds) {
  if ($content -match $bad) {
    throw "Build verification failed: main.dart.js still references forbidden project '$bad'. Check lib/firebase_options.dart."
  }
}

$builtAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$mainBytes = (Get-Item $mainJs).Length

$manifest = @{
  app             = "jeeprep_admin_web"
  firebaseProject = $expectedProjectId
  builtAt         = $builtAt
  mainDartJsBytes = $mainBytes
} | ConvertTo-Json -Compress
$manifestPath = Join-Path (Get-Location) "build\web\deploy_manifest.json"
Set-Content -Path $manifestPath -Value $manifest -Encoding UTF8

# version.json is already on the server and not rewritten — use it to verify deploy.
$versionPath = Join-Path (Get-Location) "build\web\version.json"
$version = @{
  app_name         = "jeeprep_admin_web"
  version          = "1.0.0"
  build_number     = "1"
  package_name     = "jeeprep_admin_web"
  firebase_project = $expectedProjectId
  built_at         = $builtAt
  main_dart_js_bytes = $mainBytes
} | ConvertTo-Json -Compress
Set-Content -Path $versionPath -Value $version -Encoding UTF8

# Cloudflare/CDN often keeps an old main.dart.js at the bare URL even after FTP replace.
# Append a build id so browsers fetch the new bundle (mainn.dart.js worked for this reason).
$cacheBust = ($builtAt -replace '[^0-9]', '')
$bootstrapPath = Join-Path (Get-Location) "build\web\flutter_bootstrap.js"
$bootstrap = Get-Content -Raw -Path $bootstrapPath
$mainJsWithQuery = "main.dart.js?v=$cacheBust"
if ($bootstrap -notmatch [regex]::Escape($mainJsWithQuery)) {
  $bootstrap = $bootstrap -replace '"mainJsPath":"main\.dart\.js"', "`"mainJsPath`":`"$mainJsWithQuery`""
  Set-Content -Path $bootstrapPath -Value $bootstrap -NoNewline -Encoding UTF8
}

Write-Host ""
Write-Host "Build verified for Firebase project $expectedProjectId." -ForegroundColor Green
Write-Host "main.dart.js cache-bust: ?v=$cacheBust (in flutter_bootstrap.js)" -ForegroundColor Green
Write-Host "Deploy manifest: $manifestPath" -ForegroundColor Green
Write-Host "After upload, verify: https://jeeappadmin.satlas.org/version.json" -ForegroundColor Yellow
Write-Host "  (must show firebase_project: $expectedProjectId)" -ForegroundColor Yellow
Write-Host "Deploy the contents of:" -ForegroundColor Green
Write-Host "  $(Join-Path (Get-Location) 'build\web')" -ForegroundColor White
