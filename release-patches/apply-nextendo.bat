@echo off
rem Puts Nextendo online play into the engine the NX2Apple v1.4.0 Windows release bundles.
rem Run it from the engine folder: ...\NX2Apple-windows-x64\NX2Apple\engine
rem One patch, applied whole: it either goes in completely or changes nothing at all.
setlocal
if not exist dm\host\hle_net.c (
  echo Run this from the engine folder, e.g. C:\Users\you\Downloads\NX2Apple-windows-x64\NX2Apple\engine
  exit /b 1
)
set BASE=https://raw.githubusercontent.com/yewsiff/NX2Apple/nextendo-online/release-patches
set NAME=nextendo-for-v1.4.0
curl -sSL -o "%TEMP%\%NAME%.patch" %BASE%/%NAME%.patch
if errorlevel 1 (
  echo Could not download the patch. Check the connection and run this again.
  exit /b 1
)
rem Whether it is already in is asked of the patch itself, not of a marker word: reversing a patch
rem only checks out when every one of its changes is present, so a half patched folder cannot pass.
git apply --check -R --ignore-whitespace "%TEMP%\%NAME%.patch" 2>nul
if not errorlevel 1 (
  echo Nextendo is already in this engine. Rebuild the game in the launcher.
  exit /b 0
)
git apply --ignore-whitespace "%TEMP%\%NAME%.patch" 2>nul
if not errorlevel 1 (
  echo Nextendo is in. Rebuild the game in the launcher.
  exit /b 0
)
echo.
echo This is not the clean v1.4.0 engine the patch is cut against, and nothing was changed.
echo.
echo Most often that means the folder is half patched: an NX2Apple update refreshes the engine
echo files that changed and leaves the rest, so part of an older patch set is still sitting in it.
echo.
echo The cure: delete this engine folder, extract it again from the NX2Apple v1.4.0 download,
echo and run this script once. Nothing else in NX2Apple needs touching.
echo.
echo Still on NX2Apple v1.3.0? Run apply-nextendo-v1.3.0.bat instead.
echo.
echo The lines below name the files that disagree:
git apply --check --ignore-whitespace --verbose "%TEMP%\%NAME%.patch"
exit /b 1
