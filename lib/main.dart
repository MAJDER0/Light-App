import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MaterialApp(
    home: BluetoothControlScreen(),
  ));
}

class BluetoothControlScreen extends StatefulWidget {
  @override
  _BluetoothControlScreenState createState() => _BluetoothControlScreenState();
}

class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  late BluetoothConnection connection; // Declare as late

  bool isConnected = false;
  bool isLightOn = false;

  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    // Moved the startDiscovery call to initState
    startDiscovery();
  }

  Future<void> startDiscovery() async {
    try {
      // Clear the existing list of devices when starting a new discovery
      setState(() {
        devices.clear();
      });

      // Use Stream.forEach() to process each result individually
      await for (BluetoothDiscoveryResult result in bluetooth.startDiscovery()) {
        // Only add unique devices to the list
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    } catch (exception) {
      print('Error discovering devices: $exception');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Cancel discovery before connecting
      await bluetooth.cancelDiscovery();

      connection = await BluetoothConnection.toAddress(device.address!);
      setState(() {
        isConnected = true;
        selectedDevice = device;
      });

      // Set up a listener for disconnection
      connection.input!.listen(
            (Uint8List data) {},
        onDone: () {
          setState(() {
            isConnected = false;
            selectedDevice = null;
          });
        },
        onError: (error) {
          print('Error listening to socket: $error');
        },
      );
    } catch (exception) {
      print('Error connecting: $exception');
    }
  }

  Future<void> disconnectFromDevice() async {
    if (isConnected) {
      await connection.close();
      setState(() {
        isConnected = false;
        selectedDevice = null;
      });
    }
  }

  Future<BluetoothDevice?> showDeviceListDialog() async {
    return showDialog<BluetoothDevice>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose a Device'),
          content: Column(
            children: devices.map((device) {
              return ListTile(
                title: Text(device.name ?? 'Unknown Device'),
                onTap: () {
                  Navigator.pop(context, device);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> connectToSelectedDevice() async {
    // Display discovered devices in a dialog
    BluetoothDevice? selectedDevice = await showDeviceListDialog();

    print('Selected Device: $selectedDevice');

    // Connect to the selected Bluetooth device
    if (selectedDevice != null) {
      await connectToDevice(selectedDevice);
    } else {
      print('No device selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Light App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF161616),
      ),
      backgroundColor: Color(0xFF161616),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Check if Bluetooth is enabled
                bool isBluetoothEnabled = (await bluetooth.isOn) ?? false;

                if (isBluetoothEnabled) {
                  // Bluetooth is already on, connect to the selected device
                  await connectToSelectedDevice();
                } else {
                  // Bluetooth is off, request to turn it on
                  bool? enableBluetooth = await bluetooth.requestEnable();
                  if (enableBluetooth != null && enableBluetooth != false) {
                    // Bluetooth is enabled, connect to the selected device
                    await connectToSelectedDevice();
                  } else {
                    print('Bluetooth is not enabled.');
                  }
                }
              },
              child: Text('CONNECT TO BLUETOOTH'),
            ),
            SizedBox(height: 20), // Even space between buttons
            ElevatedButton(
              onPressed: () async {
                // Trigger Bluetooth discovery to find available devices
                await startDiscovery();
                // Optionally, you can update the UI here to show the discovered devices.
              },
              child: Text('LOOK FOR DEVICES'),
            ),
            SizedBox(height: 20), // Even space between buttons
            if (isConnected)
              ElevatedButton(
                onPressed: () async {
                  await disconnectFromDevice();
                },
                child: Text('DISCONNECT DEVICE'), // Changed button text
              ),
            SizedBox(height: 20), // Even space between buttons
            Text(
              isConnected ? 'CONNECTED: ${selectedDevice?.name}' : '',
              style: TextStyle(fontSize: 18, color: isConnected ? Colors.green : Colors.white), // Changed text color
            ),
            SizedBox(height: 20), // Even space between buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TURN ',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Switch(
                  value: isLightOn,
                  onChanged: (value) async {
                    // Handle light switch logic here
                    setState(() {
                      isLightOn = value;
                    });
                    if (isConnected) {
                      connection.output.add(Uint8List.fromList(isLightOn ? [0] : [1]));

                      // await the Future returned by allSent to ensure the write operation is completed
                      await connection.output.allSent;
                    }
                  },
                ),
                Text(
                  isLightOn ? 'ON' : 'OFF',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20), // Even space between buttons
            Text(
              'THE LIGHT IS CURRENTLY ${isLightOn ? 'ON' : 'OFF'}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
