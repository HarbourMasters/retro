Remove-Item -Force lib/auto/build.dart
New-Item -ItemType File -Path lib/auto/build.dart

$BRANCH = git rev-parse --abbrev-ref HEAD
$COMMIT_HASH = git rev-parse --short HEAD
$COMMIT_DATE = git show -s --format=%ci

"const String branch = '$BRANCH';" | Out-File -FilePath lib/auto/build.dart -Encoding utf8
"const String commitHash = '$COMMIT_HASH';" | Out-File -FilePath lib/auto/build.dart -Encoding utf8 -Append
"const String commitDate = '$COMMIT_DATE';" | Out-File -FilePath lib/auto/build.dart -Encoding utf8 -Append
