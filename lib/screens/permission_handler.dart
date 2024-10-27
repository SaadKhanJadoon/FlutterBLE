import 'package:bluettoth_project/screens/NewConnectionClient.dart';
import 'package:bluettoth_project/screens/NewConnectionServer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Bluetooth Permission Example')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => requestBluetoothPermission(context),
            child: const Text('Request Bluetooth Permission'),
          ),
        ),
      ),
    );
  }

  Future<void> requestBluetoothPermission(BuildContext context) async {
    var status = await Permission.bluetooth.request();
    var status1 = await Permission.bluetoothScan.request();
    var status2 = await Permission.bluetoothConnect.request();
    var status3 = await Permission.bluetoothAdvertise.request();

    if (status.isGranted && status1.isGranted && status2.isGranted && status3.isGranted) {
      // Check if Bluetooth is enabled
      bool isBluetoothOn = await FlutterBluePlus.isOn;

      if (!isBluetoothOn) {
        // Show dialog to enable Bluetooth
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Enable Bluetooth'),
              content: const Text(
                  'Bluetooth is required to proceed. Please enable Bluetooth.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await FlutterBluePlus
                        .turnOn(); // Method to turn on Bluetooth
                    Navigator.pop(context);
                    // Navigate to BLE Scanner screen
                    Navigator.push(
                      context,
                      //MaterialPageRoute(builder: (context) => BluetoothServerPage()),
                      MaterialPageRoute(builder: (context) => BluetoothClientPage()),
                    );
                  },
                  child: const Text('Enable'),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.push(
          context,
          //MaterialPageRoute(builder: (context) => BluetoothServerPage()),
          MaterialPageRoute(builder: (context) => BluetoothClientPage()),
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Permission not granted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void checkPermissionsAndStart(BuildContext context) async {
    if (await _checkPermissions(context)) {
      await _checkAndRequestLocationServices(context);
    }
  }

  Future<bool> _checkPermissions(BuildContext context) async {
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus != PermissionStatus.granted) {
      _showPermissionDialog(context);
      return false;
    }
    return true;
  }

  Future<void> _checkAndRequestLocationServices(BuildContext context) async {
    bool serviceEnabled = await Permission.location.serviceStatus.isEnabled;
    if (!serviceEnabled) {
      _showLocationServicesDialog(context);
    } else {
      Navigator.push(
        context,
        //MaterialPageRoute(builder: (context) => BluetoothServerPage()),
        MaterialPageRoute(builder: (context) => BluetoothClientPage()),
      );
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text('Location permission is required for Bluetooth device discovery.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                checkPermissionsAndStart(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showLocationServicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enable Location Services'),
          content: Text('Location services need to be enabled for Bluetooth device discovery.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _enableLocationServices(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _enableLocationServices(BuildContext context) async {
    await Permission.locationAlways.request(); // This will prompt the user to enable location services
    bool serviceEnabled = await Permission.location.serviceStatus.isEnabled;
    if (serviceEnabled) {
      Navigator.push(
        context,
        //MaterialPageRoute(builder: (context) => BluetoothServerPage()),
        MaterialPageRoute(builder: (context) => BluetoothClientPage()),
      );
    }
  }
}
