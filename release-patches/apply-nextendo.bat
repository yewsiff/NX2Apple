@echo off
rem Applies the Nextendo patches to the engine the NX2Apple v1.3.0 Windows release bundles, in order, skipping any already applied.
rem Run it from the engine folder: ...\NX2Apple-windows-x64\NX2Apple\engine
setlocal
if not exist dm\host\hle_net.c (
  echo Run this from the engine folder, e.g. C:\Users\you\Downloads\NX2Apple-windows-x64\NX2Apple\engine
  exit /b 1
)
set BASE=https://raw.githubusercontent.com/yewsiff/NX2Apple/nextendo-online/release-patches
call :one nextendo-for-v1.3.0 "if exist dm\host\net_online.h (exit /b 0) else (exit /b 1)" || exit /b 1
call :one nextendo-mk8-for-v1.3.0 "findstr /c:nx_is_server dm\host\net_online.h" || exit /b 1
call :one nextendo-winbuild-for-v1.3.0 "findstr /c:net_nextendo_apple.m dm\host\web_apple.m" || exit /b 1
call :one nextendo-bridgelog-for-v1.3.0 "findstr /c:logHead dm\host\net_nextendo_apple.m" || exit /b 1
echo All Nextendo patches are in. Rebuild the game in the launcher.
exit /b 0

:one
cmd /c %~2 >nul 2>&1
if not errorlevel 1 (
  echo %1: already applied
  exit /b 0
)
curl -sSL -o "%TEMP%\%1.patch" %BASE%/%1.patch || (echo %1: download failed & exit /b 1)
git apply "%TEMP%\%1.patch" || (echo %1: FAILED to apply, send the lines above & exit /b 1)
echo %1: applied
exit /b 0
