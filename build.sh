rm -f lib/auto/build.dart
touch lib/auto/build.dart
BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_DATE=$(git show -s --format=%ci)

echo "const String branch = '$BRANCH';" > lib/auto/build.dart
echo "const String commitHash = '$COMMIT_HASH';" >> lib/auto/build.dart
echo "const String commitDate = '$COMMIT_DATE';" >> lib/auto/build.dart