@echo off
rem Applies the Nextendo patches to the engine the NX2Apple v1.3.0 Windows release bundles, in order, skipping any already applied.
rem Run it from the engine folder: ...\NX2Apple-windows-x64\NX2Apple\engine
setlocal
if not exist dm\host\hle_net.c (
  echo Run this from the engine folder, e.g. C:\Users\you\Downloads\NX2Apple-windows-x64\NX2Apple\engine
  exit /b 1
)
set BASE=https://raw.githubusercontent.com/yewsiff/NX2Apple/nextendo-online/release-patches
rem Each line: the patch, and a marker that is already in the files when that patch is in.
rem Markers are single tokens on purpose: quotes and parentheses inside the argument break cmd parsing.
call :one nextendo-for-v1.3.0 NX_CLIENT_ID_DEFAULT dm\host\net_online.h || exit /b 1
call :one nextendo-mk8-for-v1.3.0 nx_is_server dm\host\net_online.h || exit /b 1
call :one nextendo-winbuild-for-v1.3.0 net_nextendo_apple.m dm\host\web_apple.m || exit /b 1
call :one nextendo-bridgelog-for-v1.3.0 logHead dm\host\net_nextendo_apple.m || exit /b 1
call :one nextendo-wsfix-for-v1.3.0 ws_fix_answer dm\host\net_nextendo_apple.m || exit /b 1
call :one nextendo-trace-for-v1.3.0 ws_fix_accept dm\host\net_nextendo_apple.m || exit /b 1
call :one nextendo-fd3-for-v1.3.0 SK_FD_FIRST dm\host\hle_net.c || exit /b 1
call :one nextendo-errno-for-v1.3.0 sk_err_linux dm\host\hle_net.c || exit /b 1
call :one nextendo-secure-for-v1.3.0 uint16_t dm\host\net_online.h || exit /b 1
call :one nextendo-udp-for-v1.3.0 park_take dm\host\hle_net.c || exit /b 1
call :one nextendo-piatrace-for-v1.3.0 rawn dm\host\net_nextendo_apple.m || exit /b 1
call :one nextendo-ioctl-for-v1.3.0 on_ioctl dm\host\hle_net.c || exit /b 1
call :one nextendo-nifmtrace-for-v1.3.0 resolver_called dm\host\hle_net.c || exit /b 1
call :one nextendo-nsd-for-v1.3.0 nsd_resolve_online dm\host\hle_misc.c || exit /b 1
echo.
echo All Nextendo patches are in. Rebuild the game in the launcher.
exit /b 0

rem %1 patch name, %2 a marker token, %3 the file it appears in once the patch is applied
:one
if exist %3 findstr /c:%2 %3 >nul 2>&1 && (
  echo %1: already applied
  exit /b 0
)
curl -sSL -o "%TEMP%\%1.patch" %BASE%/%1.patch
if errorlevel 1 (
  echo %1: download failed
  exit /b 1
)
git apply "%TEMP%\%1.patch" 2>nul
if not errorlevel 1 (
  echo %1: applied
  exit /b 0
)
rem Git for Windows may have written the files with CRLF line endings; retry tolerating that.
git apply --ignore-whitespace "%TEMP%\%1.patch" 2>nul
if not errorlevel 1 (
  echo %1: applied ^(ignoring line endings^)
  exit /b 0
)
echo %1: FAILED to apply, the lines below say why
git apply --ignore-whitespace --verbose "%TEMP%\%1.patch"
exit /b 1
