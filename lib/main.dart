import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.deepPurple),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      home: Anasayfa(),
    );
  }
}

class Anasayfa extends StatefulWidget {
  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  bool kontrol = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("YUSUF"),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                enableBluetooth();
              },
              child: const Text("BLUETOOTH AÇ"),

            ),
            Padding(
              padding: const EdgeInsets.only(top: 600),

              child: ElevatedButton(
                onPressed: () {
                  _navigateToBluetoothPage(context);
                },
                child: const Text("BLUETOOTH CİHAZLARINI LİSTELE"),

              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBluetoothPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BluetoothPage()),
    ).then((selectedDevice) {
      if (selectedDevice != null) {
        _connectToDevice(selectedDevice);
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');

      connection.input?.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
          connection.finish(); // Closing connection
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (exception) {
      print('Cannot connect, exception occurred');
    }
  }
}

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _getBluetoothDevices();
  }

  Future<void> _getBluetoothDevices() async {
    try {
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLUETOOTH CİHAZLARINI LİSTELE'),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_devices[index].name ?? ""),
            onTap: () {
              Navigator.pop(context, _devices[index]);
            },
          );
        },
      ),
    );
  }
}
void enableBluetooth() async {
  FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;

  bool? isEnabled = await flutterBluetoothSerial.isEnabled;

  if (isEnabled != null && !isEnabled) {
    await flutterBluetoothSerial.requestEnable();
  }
}
