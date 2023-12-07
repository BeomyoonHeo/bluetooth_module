import 'dart:async';

import 'package:bluetooth_module/bluetooth_module.dart';
import 'package:flutter/material.dart';

class BluetoothList extends StatefulWidget {
  const BluetoothList({super.key});

  @override
  State<BluetoothList> createState() => _BluetoothListState();
}

class _BluetoothListState extends State<BluetoothList> {
  StreamSubscription<bool>? _subscription;
  final List<ClassicDevice> _list = [];
  final List<BleDevice> _bleList = [];

  void _listenDiscover() => _subscription = BluetoothManager().isDiscovering.listen((isDiscovering) {
        if (!isDiscovering) {
          setState(() {
            _list.addAll(BluetoothManager().lastClassicResults);
            _bleList.addAll(BluetoothManager().lastBleResults);
          });
        } else {
          setState(() {
            _list.clear();
          });
        }
      });

  @override
  void initState() {
    super.initState();
    _listenDiscover();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
            child: ListView.builder(
          itemCount: _list.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () async {
                await BluetoothManager().bondDevice(_list[index].address);
                BluetoothManager().connectedDevices();
              },
              child: ListTile(
                title: Text(_list[index].name ?? 'Unknown'),
                subtitle: Text(_list[index].address),
                onTap: () async {
                  //await BluetoothManager().connectDevice(_list[index].device.address);
                },
              ),
            );
          },
        )),
        Flexible(
          child: ListView.builder(
            itemCount: _bleList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () async {
                  await BluetoothManager().bondDevice(_bleList[index].remoteId.str);
                  BluetoothManager().connectedDevices();
                },
                child: ListTile(
                  title: Text(_bleList[index].advName),
                  subtitle: Text(_bleList[index].remoteId.str),
                  onTap: () async {
                    await BluetoothManager().connectDevice(bleDevice: _bleList[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
