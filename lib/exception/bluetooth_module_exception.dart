class BluetoothModuleException implements Exception {
  final String message;

  BluetoothModuleException(this.message);
}

class UnsupportedPlatformException extends BluetoothModuleException {
  UnsupportedPlatformException({String? message}) : super(message ?? 'Unsupported platform');
}
