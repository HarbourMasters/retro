import 'package:intl/intl.dart';
import 'package:retro/auto/build.dart';


class GitInfo {

  GitInfo({required this.branch, required this.commitHash, this.commitDate = ''});

  final String branch;
  final String commitHash;
  final String commitDate;
}

class GitLoader {

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static Future<GitInfo> getGitInfo() async {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(commitDate) * 1000);
    return GitInfo(branch: branch, commitHash: commitHash, commitDate:  _dateFormat.format(date));
  }
}