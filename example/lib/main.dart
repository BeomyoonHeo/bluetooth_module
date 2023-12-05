import 'dart:async';

import 'package:bluetooth_module/bluetooth_module.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  @override
  void initState() {
    super.initState();
    _subscription ??= BluetoothManager().currentOnOffState.listen((event) {
      setState(() {
        isBluetoothEnabled = event;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
        ]),
      ),
    );
  }
}
