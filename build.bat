@echo off

if exist lib\auto\build.dart del /f lib\auto\build.dart
type nul > lib\auto\build.dart

for /f "delims=" %%i in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%i
for /f "delims=" %%i in ('git rev-parse HEAD') do set COMMIT_HASH=%%i
for /f "delims=" %%i in ('git show -s --format=%%ci') do set COMMIT_DATE=%%i

echo const String branch = '%BRANCH%'; > lib\auto\build.dart
echo const String commitHash = '%COMMIT_HASH%'; >> lib\auto\build.dart
echo const String commitDate = '%COMMIT_DATE%'; >> lib\auto\build.dart