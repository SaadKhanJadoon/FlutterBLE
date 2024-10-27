import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BluetoothClientPage extends StatefulWidget {
  @override
  _BluetoothClientPageState createState() => _BluetoothClientPageState();
}

class _BluetoothClientPageState extends State<BluetoothClientPage> {
  static const platform = MethodChannel('com.example.bluetooth/client');
  String connectionStatus = 'Disconnected';
  String receivedData = '';
  bool isMethodCallHandlerSet = false;

  @override
  void initState() {
    super.initState();
    startClient();
    setMethodCallHandler();
  }

  @override
  void dispose() {
    // Remove the method call handler
    stopClient();
    platform.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> stopClient() async {
    try {
      final String result = await platform.invokeMethod('stopClient');
      print('stop client: $result');
    } on PlatformException catch (e) {
      print("Failed to stop client: '${e.message}'.");
    }
  }

  Future<void> startClient() async {
    try {
      final String result = await platform.invokeMethod('startClient');
      setState(() {
        connectionStatus = result;
      });
      print('Connection Status updated to: $connectionStatus');
    } on PlatformException catch (e) {
      print("Failed to start client: '${e.message}'.");
    }
  }

  void setMethodCallHandler() {
    if (!isMethodCallHandlerSet) {
      platform.setMethodCallHandler((call) async {
        print("Method call received: ${call.method}");
        if (call.method == 'receiveData') {
          print("Method call received flutter1: ${call.arguments}");
          setState(() {
            print("Method call received flutter2: ${call.arguments}");
            receivedData = call.arguments;
          });
          print("Received data flutter3: ${call.arguments}");
        }
      });
      isMethodCallHandlerSet = true; // Set the flag to true
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Client'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Connection Status: $connectionStatus'),
            if (receivedData.isNotEmpty) Text('Received Data: $receivedData'),
            if (receivedData.isEmpty && connectionStatus != 'Connected')
              Text('No data received yet'),
          ],
        ),
      ),
    );
  }
}
