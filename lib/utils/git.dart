import 'package:intl/intl.dart';
import 'package:retro/auto/build.dart';


class GitInfo {

  GitInfo({required this.branch, required this.commitHash, this.commitDate = ''});

  final String branch;
  final String commitHash;
  final String commitDate;
}

class GitLoader {
  static GitInfo getGitInfo() {
    return GitInfo(branch: branch, commitHash: commitHash, commitDate: commitDate.split(' -').first);
  }
}