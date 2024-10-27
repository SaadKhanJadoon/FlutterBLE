import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CharacteristicScreen extends StatelessWidget {
  final BluetoothDevice device;

  CharacteristicScreen({required this.device});

  Future<void> readCharacteristic(BluetoothDevice device, Guid characteristicId) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          List<int> value = await characteristic.read();
          print('Read value: $value');
        }
      }
    }
  }

  Future<void> writeCharacteristic(BluetoothDevice device, Guid characteristicId, List<int> data) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          await characteristic.write(data);
          print('Data written successfully.');
        }
      }
    }
  }

  Future<void> subscribeToNotifications(BluetoothDevice device, Guid characteristicId) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            print('Notification received: $value');
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Characteristics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Read Characteristic'),
              onPressed: () {
                readCharacteristic(device, Guid('YOUR_CHARACTERISTIC_UUID'));
              },
            ),
            ElevatedButton(
              child: Text('Write Characteristic'),
              onPressed: () {
                writeCharacteristic(device, Guid('YOUR_CHARACTERISTIC_UUID'), [0x12, 0x34]);
              },
            ),
            ElevatedButton(
              child: Text('Subscribe to Notifications'),
              onPressed: () {
                subscribeToNotifications(device, Guid('YOUR_CHARACTERISTIC_UUID'));
              },
            ),
          ],
        ),
      ),
    );
  }
}