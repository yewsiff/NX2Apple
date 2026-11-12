@echo off
rem Puts Nextendo online play into the engine the NX2Apple v1.4.0 Windows release bundles.
rem Run it from the engine folder: ...\NX2Apple-windows-x64\NX2Apple\engine
rem Safe to run again: it brings an engine already carrying an older version of the patch up to date
rem by reversing that version first, so the folder never has to be extracted again.
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
rem Whether this exact version is in is asked of the patch itself: reversing it only checks out
rem when every one of its changes is present, so a half patched folder cannot pass.
git apply --check -R --ignore-whitespace "%TEMP%\%NAME%.patch" 2>nul
if not errorlevel 1 (
  echo Nextendo is already in this engine, and up to date. Nothing to do.
  exit /b 0
)
git apply --ignore-whitespace "%TEMP%\%NAME%.patch" 2>nul
if not errorlevel 1 (
  echo Nextendo is in. Rebuild the game in the launcher.
  exit /b 0
)
rem An older version of the patch may be in the folder. Each one shipped is kept, newest first:
rem reversing the one that is actually there puts the folder back to stock, and then this one goes in.
curl -sSL -o "%TEMP%\nx-history.txt" %BASE%/v140-history/list.txt 2>nul
if not exist "%TEMP%\nx-history.txt" goto :stuck
set FOUND=
for /f "usebackq eol=# tokens=*" %%i in ("%TEMP%\nx-history.txt") do (
  if not defined FOUND (
    curl -sSL -o "%TEMP%\nx-old.patch" %BASE%/v140-history/%%i.patch 2>nul
    git apply -R --ignore-whitespace "%TEMP%\nx-old.patch" 2>nul
    if not errorlevel 1 set FOUND=%%i
  )
)
if not defined FOUND goto :stuck
git apply --ignore-whitespace "%TEMP%\%NAME%.patch" 2>nul
if not errorlevel 1 (
  echo Nextendo updated from an earlier version. Rebuild the game in the launcher.
  exit /b 0
)
echo The earlier version came out cleanly but the new one would not go in, and the folder is now stock.
echo Run this script once more.
exit /b 1

:stuck
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
