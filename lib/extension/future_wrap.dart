typedef FutureCallback<T> = Future<T> Function();
typedef FutureVoidCallback = Future<void> Function();

extension FutureWrapExt<T> on Future<T> {
  Future<T?> callWithCustomError({
    FutureVoidCallback? continueFunction,
    Exception? usingCustomException,
  }) async {
    try {
      return await this;
    } catch (e) {
      if (continueFunction != null) {
        await continueFunction.call();
        return null;
      }

      if (usingCustomException != null) {
        throw usingCustomException;
      } else {
        throw Exception(e.toString());
      }
    } finally {}
  }
}
