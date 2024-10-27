
# Flutter BLE Project

A Flutter demo for Bluetooth Low Energy (BLE) that enables device scanning, connections, and data transfer between Android devices, including smartphones and Android boxes.

## Features

- Scan for BLE devices.
- Establish secure and insecure RFCOMM connections.
- Manage connections and handle data transfer.
- Support for both smartphones and Android boxes.

## Installation
   - **Clone the Repository**
      ```bash
      git clone https://github.com/yourusername/flutter_ble_project.git
      cd flutter_ble_project
      ```

   - **Install Dependencies**
      ```bash
      flutter pub get
      ```

   - **Set Up Native Code.** Ensure that the AndroidManifest.xml includes necessary Bluetooth permissions and configurations.

## Usage
   - **Run the App**
      ```bash
      flutter run
      ```

   - **Enable Bluetooth & Permissions.** The app will request permissions to enable Bluetooth. Grant them for full functionality.

   - **Scanning for Devices.** Go to the device scanning screen and tap the "Refresh" button to discover nearby devices.

   - **Connecting to a Device.** Tap on a listed device to establish a connection using insecure RFCOMM sockets.

   - **Data Transfer.** Use the provided UI controls to send and receive data between devices.

## Problem Faced & Solution:
- **Physical Device Connection.** I faced issues with unstable connections when trying to connect physical Android devices using BLE. To resolve this, I used a combination of:


   - `flutter_bluetooth_serial: ^0.4.0` for reliable classic Bluetooth connections.
   - `flutter_blue_plus: ^1.32.8` for BLE support.
Using both packages together provided better compatibility and improved connection stability across devices.

## Permissions

Required permissions:

      1. BLUETOOTH
      2. BLUETOOTH_ADMIN
      3. BLUETOOTH_SCAN
      4. BLUETOOTH_CONNECT
      5. ACCESS_FINE_LOCATION


Ensure these permissions are requested at runtime, especially on **Android 10 and above**.

## Contributing
Contributions are welcome! If you'd like to contribute:
- **Fork the repository**
- **Create a new branch** for your feature or bug fix.
- **Submit a pull request** with a detailed description of your changes.

## License
```bash
Copyright (C) 2023-2024 SaadKhan

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
