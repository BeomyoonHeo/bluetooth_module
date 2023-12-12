import 'dart:async';

import 'package:bluetooth_module/bluetooth_module.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleModelTransformer extends StreamTransformerBase<List<ScanResult>, List<BleDevice>> {
  @override
  Stream<List<BleDevice>> bind(Stream<List<ScanResult>> stream) {
    return stream.map((event) {
      return event.map((e) => BleDevice(remoteId: e.device.remoteId)).toList();
    });
  }
}
