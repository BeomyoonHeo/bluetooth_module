class BluetoothModuleException implements Exception {
  final String message;

  BluetoothModuleException(this.message);
}

class UnsupportedPlatformException extends BluetoothModuleException {
  UnsupportedPlatformException({String? message}) : super(message ?? 'Unsupported platform');
}

class ConnectionException extends BluetoothModuleException {
  ConnectionException({String? message}) : super(message ?? 'Connection failed');
}

class DeviceNotFoundException extends BluetoothModuleException {
  DeviceNotFoundException({String? message}) : super(message ?? 'Device not found');
}

class DeviceNotConnectedException extends BluetoothModuleException {
  DeviceNotConnectedException({String? message}) : super(message ?? 'Device not connected');
}

class DeviceNotBondedException extends BluetoothModuleException {
  DeviceNotBondedException({String? message}) : super(message ?? 'Device not bonded');
}

class DeviceNotDiscoveredException extends BluetoothModuleException {
  DeviceNotDiscoveredException({String? message}) : super(message ?? 'Device not discovered');
}
