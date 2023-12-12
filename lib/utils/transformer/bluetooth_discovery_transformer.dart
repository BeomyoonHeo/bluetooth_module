import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothStateTransformer<T extends BluetoothAdapterState, B extends bool> extends StreamTransformerBase<T, B> {
  @override
  Stream<B> bind(Stream<T> stream) {
    return stream.map(
      (event) {
        switch (event) {
          case BluetoothAdapterState.turningOff:
          case BluetoothAdapterState.off:
          case BluetoothAdapterState.unknown:
          case BluetoothAdapterState.unavailable:
          case BluetoothAdapterState.unauthorized:
            return false as B;
          case BluetoothAdapterState.turningOn:
          case BluetoothAdapterState.on:
            return true as B;
        }
      },
    );
  }
}
