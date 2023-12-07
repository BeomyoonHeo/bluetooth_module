import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as classic;

mixin BaseBluetoothObject {
  Future<bool> tryConnection();
  Future<bool> tryDisConnection();
}

class BleDevice extends ble.BluetoothDevice with BaseBluetoothObject {
  BleDevice({required super.remoteId});

  @override
  Future<bool> tryConnection() async {
    try {
      await connect();
      await discoverServices();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> tryDisConnection() async {
    try {
      await disconnect();
      return true;
    } catch (e) {
      rethrow;
    }
  }
}

class ClassicDevice extends classic.BluetoothDevice with BaseBluetoothObject {
  ClassicDevice({
    required super.address,
    super.name,
    super.type,
    super.bondState,
    super.isConnected,
  });

  classic.BluetoothConnection? _connection;

  @override
  Future<bool> tryConnection() async {
    try {
      if (_connection != null) return true;
      _connection ??= await classic.BluetoothConnection.toAddress(address);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> tryDisConnection() async {
    try {
      if (_connection == null) return true;
      await _connection?.finish();
      _connection = null;
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
