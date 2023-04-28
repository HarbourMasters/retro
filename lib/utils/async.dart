extension FutureExtensions<T> on Future<T> {
  static Future<List<T>> progressWait<T>(Iterable<Future<T>> futures, void Function() onSingleComplete) {
    return Future.wait<T>([for (var future in futures) future.whenComplete(onSingleComplete)]);
  }
}
