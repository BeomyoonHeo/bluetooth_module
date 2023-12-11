import 'dart:async';

import 'package:bluetooth_module/bluetooth_module.dart';
import 'package:example/bluetooth_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isBluetoothEnabled = false;
  bool isLoading = false;
  StreamSubscription<bool>? _subscription;
  bool isDiscovering = false;
  StreamSubscription<bool>? _discoveringSubscription;

  @override
  void initState() {
    super.initState();

    BluetoothManager().filteringDeviceName = ['XINGO'];
    BluetoothManager().filteringBleDeviceName = ['XINGO_BLE'];

    _subscription ??= BluetoothManager().currentOnOffState.listen((event) {
      setState(() {
        isBluetoothEnabled = event;
      });
    });
    _discoveringSubscription ??= BluetoothManager().isScan.listen((event) {
      setState(() {
        isDiscovering = event;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  Widget _buildBluetoothSet() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('current State : $isBluetoothEnabled'),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            if (isBluetoothEnabled) {
              await BluetoothManager().disableBluetooth();
            } else {
              await BluetoothManager().enableBluetooth();
            }
            setState(() {
              isLoading = false;
            });
          },
          child: isLoading
              ? const CircularProgressIndicator()
              : isBluetoothEnabled
                  ? const Text('Disable Bluetooth')
                  : const Text('Enable Bluetooth'),
        ),
        ElevatedButton(
          onPressed: isDiscovering ? null : BluetoothManager().startScan,
          child: isDiscovering ? const CircularProgressIndicator() : const Text('Scan Bluetooth'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(child: _buildBluetoothSet()),
          const Flexible(child: BluetoothList()),
        ]),
      ),
    );
  }
}
