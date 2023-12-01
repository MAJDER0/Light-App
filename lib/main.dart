import 'package:flutter/material.dart';

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
  bool isConnected = false;
  bool isLightOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Light App', // Zmieniono tytuł na "Light App"
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
              onPressed: () {
                // Handle Bluetooth connection logic here
                setState(() {
                  isConnected = !isConnected;
                });
              },
              child: Text('CONNECT TO BLUETOOTH'),
            ),
            SizedBox(height: 20),
            Text(
              isConnected ? 'CONNECTED' : '',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TURN ',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Switch(
                  value: isLightOn,
                  onChanged: (value) {
                    // Handle light switch logic here
                    setState(() {
                      isLightOn = value;
                    });
                  },
                ),
                Text(
                  isLightOn ? 'ON' : 'OFF',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
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
