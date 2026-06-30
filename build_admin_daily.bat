@echo off
setlocal EnableExtensions
cd /d "%~dp0"

title JEE Prep Admin - Daily Web Build

echo.
echo ============================================================
echo   JEE Prep Admin Web - daily release build
echo   Project: %CD%
echo   Firebase: jee-prep-app-16bd5
echo   Output:  build\web\
echo   Live:    https://jeeappadmin.satlas.org/
echo   Started: %DATE% %TIME%
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tool\build_admin_web.ps1"
if errorlevel 1 (
  echo.
  echo [FAILED] Build did not complete. Fix errors above and run again.
  echo.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo   [OK] Build finished
echo.
echo   Next: upload ALL files from:
echo         %CD%\build\web
echo   to jeeappadmin.satlas.org document root, then hard-refresh.
echo ============================================================
echo.

start "" explorer "%CD%\build\web"

pause
endlocal
