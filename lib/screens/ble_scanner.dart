import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue;

class BluetoothScanner extends StatefulWidget {
  @override
  _BluetoothScannerState createState() => _BluetoothScannerState();
}

class _BluetoothScannerState extends State<BluetoothScanner> {
  List<BluetoothDiscoveryResult> devices = [];
  bool isScanning = false;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? connection;
  String connectionStatus = 'Disconnected';

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.cancelDiscovery();
    connection?.close();
    super.dispose();
  }

  void startScanning() async {
    setState(() {
      devices.clear();
      isScanning = true;
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        devices.add(r);
      });
    }).onDone(() {
      setState(() {
        isScanning = false;
      });
    });

    // Stop scanning after 10 seconds
    Timer(Duration(seconds: 10), () {
      FlutterBluetoothSerial.instance.cancelDiscovery();
      setState(() {
        isScanning = false;
      });
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      print('Connecting to ${device.name}');
      setState(() {
        connectionStatus = 'Connecting...';
      });

      // Ensure the device is paired
      if (!device.isBonded) {
        bool? bonded = await FlutterBluetoothSerial.instance.bondDeviceAtAddress(device.address);
        if (!bonded!) {
          print('Failed to pair with the device');
          setState(() {
            connectionStatus = 'Failed to pair';
          });
          return;
        }
      }

      // Use flutter_blue for connection and service discovery
      flutter_blue.FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
      flutter_blue.BluetoothDevice? bleDevice;

      await flutter_blue.FlutterBluePlus.scanResults.listen((results) {
        for (flutter_blue.ScanResult result in results) {
          if (result.device.id.id == device.address) {
            bleDevice = result.device;
            break;
          }
        }
      }).asFuture();

      flutter_blue.FlutterBluePlus.stopScan();

      if (bleDevice == null) {
        setState(() {
          connectionStatus = 'Device not found in BLE scan';
        });
        return;
      }

      await bleDevice?.connect();
      setState(() {
        connectionStatus = 'Connected to ${device.name} via BLE';
      });

      // Discover services and characteristics
      List<flutter_blue.BluetoothService>? services = await bleDevice?.discoverServices();
      for (flutter_blue.BluetoothService service in services!) {
        for (flutter_blue.BluetoothCharacteristic characteristic in service.characteristics) {
          print('Characteristic found: ${characteristic.uuid}');
          // You can interact with the characteristic here
        }
      }

      // Listen for state changes
      bleDevice?.state.listen((state) {
        print("coming in updating state");
        if (state == flutter_blue.BluetoothDeviceState.connected) {
          setState(() {
            connectionStatus = 'Connected to ${device.name} via BLE';
          });
        } else if (state == flutter_blue.BluetoothDeviceState.disconnected) {
          setState(() {
            connectionStatus = 'Disconnected';
          });
        }
      });
    } catch (e) {
      print('Cannot connect, exception occurred');
      print(e);
      setState(() {
        connectionStatus = 'Failed to connect';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : startScanning,
            child: Text('Start Scanning'),
          ),
          Text('Status: $connectionStatus'),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                BluetoothDiscoveryResult result = devices[index];
                return ListTile(
                  title: Text(result.device.name ?? 'Unknown Device'),
                  subtitle: Text(result.device.address),
                  onTap: () => connectToDevice(result.device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
