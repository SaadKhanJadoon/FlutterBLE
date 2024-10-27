import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothServerPage extends StatefulWidget {
  const BluetoothServerPage({super.key});

  @override
  _BluetoothServerPageState createState() => _BluetoothServerPageState();
}

class _BluetoothServerPageState extends State<BluetoothServerPage> {
  final TextEditingController _controller = TextEditingController();
  static const platform = MethodChannel('com.example.bluetooth/server');
  String connectionStatus = 'Disconnected';
  List<BluetoothDevice> devicesList = [];
  bool isConnected = false;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;

  final Map<String, String> prayerTimesMap = {
    "fajrTime": "05:00 AM",
    "zuhrTime": "1:30 PM",
    "asrTime": "04:15 PM",
    "maghribTime": "07:45 PM",
    "ishaTime": "09:00 PM",
    "jummaTime": "01:30 PM",
  };

  @override
  void initState() {
    super.initState();
    getPairedDevicesAndConnect();
    startScanning();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void getPairedDevicesAndConnect() async {
    try {
      List<BluetoothDevice> pairedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        devicesList.addAll(pairedDevices);
      });

      for (BluetoothDevice device in pairedDevices) {
        print("Attempting to connect to ${device.name} (${device.address})");
        await connectToDevice(device.address);
        if (isConnected) {
          print("Successfully connected to ${device.name} (${device.address})");
          break;
        }
      }
    } catch (e) {
      print("Error retrieving paired devices: $e");
    }
  }

  void startScanning() {
    _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      if (!devicesList.contains(r.device)) {
        setState(() {
          devicesList.add(r.device);
        });
      }
    });

    // Stop scanning after 10 seconds
    Timer(const Duration(seconds: 10), () {
      _streamSubscription?.cancel();
      print('Stopped scanning for devices');
    });
  }

  Future<void> connectToDevice(String address) async {
    if (isConnected) {
      // Already connected, ignore the new connection attempt
      print("Already connected to a device");
      return;
    }

    try {
      final String result = await platform.invokeMethod('connectToDevice', {'address': address});
      setState(() {
        connectionStatus = result;
        isConnected = result.startsWith('Connected');
      });
      print("Connection result: $result");

      if (isConnected) {
        // Stop scanning when connected
        _streamSubscription?.cancel();
        print('Stopped scanning due to successful connection');
      }
    } on PlatformException catch (e) {
      print("Failed to connect to device: '${e.message}'.");
    }
  }

  Future<void> sendData(String data) async {
    if (isConnected) {
      try {
        final String result = await platform.invokeMethod('sendData', {'data': data});
        print("Send data result: $result");
      } on PlatformException catch (e) {
        print("Failed to send data: '${e.message}'.");
      }
    } else {
      setState(() {
        connectionStatus = 'No devices connected';
      });
      print("No devices connected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Server'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Connection Status: $connectionStatus'),
            Expanded(
              child: ListView.builder(
                itemCount: devicesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devicesList[index].name ?? "Unknown Device"),
                    subtitle: Text(devicesList[index].address),
                    onTap: () => connectToDevice(devicesList[index].address),
                  );
                },
              ),
            ),
            if (isConnected)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => sendData(prayerTimesMap.toString()),
                      child: const Text('Send Hashmap Data'),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

