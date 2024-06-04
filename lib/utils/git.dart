import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GitInfo {

  GitInfo({required this.branch, required this.commitHash, this.commitDate = ''});

  final String branch;
  final String commitHash;
  final String commitDate;
}

class GitLoader {

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static Future<GitInfo> getGitInfo() async {
    final head = (await rootBundle.loadString('.git/HEAD')).trim();
    final commitId = (await rootBundle.loadString('.git/ORIG_HEAD')).substring(0, 7);
    final commitDate = (await rootBundle.loadString('.git/logs/HEAD')).split('\n').first.split(' ')[4];
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(commitDate) * 1000);
    final branch = head.split('/').last;

    return GitInfo(branch: branch, commitHash: commitId, commitDate: _dateFormat.format(date));
  }
}