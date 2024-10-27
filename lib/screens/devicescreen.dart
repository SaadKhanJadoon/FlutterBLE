import 'package:bluettoth_project/screens/characteristics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatelessWidget {
  final BluetoothDevice device;

  DeviceScreen({required this.device});

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }

  @override
  Widget build(BuildContext context) {
    connectToDevice(device);

    return Scaffold(
      appBar: AppBar(
        title: Text('Device: ${device.name}'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('View Characteristics'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CharacteristicScreen(device: device),
              ),
            );
          },
        ),
      ),
    );
  }
}